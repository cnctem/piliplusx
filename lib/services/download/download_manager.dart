import 'dart:async' show Completer, StreamSubscription;
import 'dart:io';

import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:dio/dio.dart';

class DownloadManager {
  final String url;
  final String path;
  final Function({required int progress, required int total}) onTaskRunning;
  final Function() onTaskComplete;
  final Function({
    required int progress,
    required int total,
    required Object error,
  })
  onTaskError;

  bool _closed = false;
  DownloadStatus _status = DownloadStatus.wait;
  DownloadStatus get status => _status;
  CancelToken? _cancelToken;
  Completer? _completer;

  DownloadManager({
    required this.url,
    required this.path,
    required this.onTaskRunning,
    required this.onTaskComplete,
    required this.onTaskError,
  });

  void _complete() {
    if (_completer?.isCompleted == false) {
      _completer?.complete();
    }
  }

  Future<void> start() async {
    _completer = Completer();
    _cancelToken = CancelToken();
    _status = DownloadStatus.downloading;

    final file = File(path);
    // If the file already exists, the method fails.
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    final int downloadedSize = await file.length();

    // Shouldn't call file.writeAsBytesSync(list, flush: flush),
    // because it can write all bytes by once. Consider that the file is
    // a very big size (up to 1 Gigabytes), it will be expensive in memory.
    RandomAccessFile raf = file.openSync(
      mode: downloadedSize == 0 ? FileMode.write : FileMode.append,
    );

    Future<void>? asyncWrite;
    Future<void> closeAndDelete({bool delete = false}) async {
      if (!_closed) {
        _closed = true;
        await asyncWrite;
        await raf.close().catchError((_) => raf);
        if (delete && file.existsSync()) {
          await file.delete().catchError((_) => file);
        }
      }
    }

    final Response<ResponseBody> response;
    try {
      response = await Request.dio.get<ResponseBody>(
        url.http2https,
        options: Options(
          headers: {'range': 'bytes=$downloadedSize-'},
          responseType: ResponseType.stream,
          validateStatus: (status) {
            return status == 416 ||
                (status != null && status >= 200 && status < 300);
          },
        ),
        cancelToken: _cancelToken,
      );
    } on DioException catch (e) {
      final isFailed = e.response?.statusCode != 416;
      if (isFailed) {
        _status = DownloadStatus.failDownload;
        onTaskError(progress: 0, total: 0, error: e);
      } else {
        _status = DownloadStatus.completed;
        onTaskComplete();
      }
      closeAndDelete(delete: isFailed);
      _complete();
      return;
    }

    int received = downloadedSize;

    // Stream<Uint8List>
    final stream = response.data!.stream;

    final total =
        int.parse(response.headers.value(Headers.contentLengthHeader) ?? '0') +
        downloadedSize;

    if (downloadedSize == 0) {
      onTaskRunning(progress: 0, total: total);
    }

    late StreamSubscription subscription;
    subscription = stream.listen(
      (data) {
        subscription.pause();
        // Write file asynchronously
        asyncWrite = raf
            .writeFrom(data)
            .then((result) async {
              // Notify progress
              received += data.length;
              onTaskRunning(progress: received, total: total);

              raf = result;
              if (_cancelToken != null && !_cancelToken!.isCancelled) {
                subscription.resume();
              }
            })
            .catchError((Object e) async {
              try {
                await subscription.cancel().catchError((_) {});
                _closed = true;
                await raf.close().catchError((_) => raf);
                if (file.existsSync()) {
                  await file.delete().catchError((_) => file);
                }
              } catch (e) {
                _status = DownloadStatus.failDownload;
                onTaskError(progress: received, total: total, error: e);
              } finally {
                _complete();
              }
            });
      },
      onDone: () async {
        try {
          await asyncWrite;
          _closed = true;
          await raf.close().catchError((_) => raf);
          _status = DownloadStatus.completed;
          onTaskComplete();
        } catch (e) {
          _status = DownloadStatus.failDownload;
          onTaskError(progress: received, total: total, error: e);
        } finally {
          _complete();
        }
      },
      onError: (e) async {
        try {
          await closeAndDelete(delete: true);
        } catch (e) {
          _cancel();
          _status = DownloadStatus.failDownload;
          onTaskError(progress: received, total: total, error: e);
        } finally {
          _complete();
        }
      },
      cancelOnError: true,
    );
    _cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await closeAndDelete();
      _complete();
    });
  }

  Future<void>? _cancel() {
    if (_cancelToken != null) {
      _cancelToken?.cancel();
      _cancelToken = null;
    }
    return _completer?.future;
  }

  Future<void>? cancel({required bool isDelete}) {
    if (!isDelete && _status == DownloadStatus.downloading) {
      _status = DownloadStatus.pause;
    }
    return _cancel();
  }
}
