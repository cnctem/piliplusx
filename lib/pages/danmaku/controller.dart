import 'dart:convert';
import 'dart:io' show File;

import 'package:PiliPlus/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:PiliPlus/grpc/dm.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

class PlDanmakuController {
  PlDanmakuController(
    this.cid,
    this.plPlayerController,
    this.isFileSource,
  ) : mergeDanmaku = plPlayerController.mergeDanmaku;

  final int cid;
  final PlPlayerController plPlayerController;
  final bool mergeDanmaku;
  final bool isFileSource;

  late final isLogin = Accounts.main.isLogin;

  Map<int, List<DanmakuElem>> dmSegMap = {};
  // 已请求的段落标记
  late final Set<int> requestedSeg = {};

  static const int segmentLength = 60 * 6 * 1000;

  void dispose() {
    closed = true;
    dmSegMap.clear();
    requestedSeg.clear();
  }

  int calcSegment(int progress) {
    return progress ~/ segmentLength;
  }

  Future<void> queryDanmaku(int segmentIndex) async {
    if (isFileSource) {
      return;
    }
    if (requestedSeg.contains(segmentIndex)) {
      return;
    }
    requestedSeg.add(segmentIndex);
    final result = await DmGrpc.dmSegMobile(
      cid: cid,
      segmentIndex: segmentIndex + 1,
    );

    if (result.isSuccess) {
      final data = result.data;
      if (data.state == 1) {
        plPlayerController.dmState.add(cid);
      }
      handleDanmaku(data.elems);
    } else {
      requestedSeg.remove(segmentIndex);
    }
  }

  void handleDanmaku(List<DanmakuElem> elems) {
    if (elems.isEmpty) return;
    late final Map<String, int> counts = {};
    if (mergeDanmaku) {
      elems.retainWhere((item) {
        int? count = counts[item.content];
        counts[item.content] = count != null ? count + 1 : 1;
        return count == null;
      });
    }

    final shouldFilter = plPlayerController.filters.count != 0;
    for (final element in elems) {
      if (element.mode == 7 && !plPlayerController.showSpecialDanmaku) {
        continue;
      }
      if (isLogin) {
        element.isSelf = element.midHash == plPlayerController.midHash;
      }
      if (!element.isSelf) {
        if (element.weight < plPlayerController.danmakuWeight ||
            (shouldFilter && plPlayerController.filters.remove(element))) {
          continue;
        }
      }
      if (mergeDanmaku) {
        final count = counts[element.content];
        if (count != 1) {
          element.count = count!;
        }
      }
      final int pos = element.progress ~/ 100; //每0.1秒存储一次
      (dmSegMap[pos] ??= []).add(element);
    }
  }

  List<DanmakuElem>? getCurrentDanmaku(int progress) {
    if (isFileSource) {
      initXmlDmIfNeeded();
    } else {
      final int segmentIndex = calcSegment(progress);
      if (!requestedSeg.contains(segmentIndex)) {
        queryDanmaku(segmentIndex);
        return null;
      }
    }
    return dmSegMap[progress ~/ 100];
  }

  bool closed = false;

  late bool _xmlDmLoaded = false;

  void initXmlDmIfNeeded() {
    if (_xmlDmLoaded) return;
    _xmlDmLoaded = true;
    _initXmlDm();
  }

  Future<void> _initXmlDm() async {
    try {
      final file = File(path.join(plPlayerController.dirPath!, 'danmaku.xml'));
      final stream = file.openRead().transform(utf8.decoder);
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        if (closed) {
          return;
        }
        buffer.write(chunk);
      }
      if (closed) {
        return;
      }
      final xmlString = buffer.toString();
      final document = XmlDocument.parse(xmlString);
      final danmakus = document.findAllElements('d').toList();
      final elems = <DanmakuElem>[];
      for (final dm in danmakus) {
        if (closed) {
          return;
        }
        try {
          final pAttr = dm.getAttribute('p');
          if (pAttr != null) {
            final parts = pAttr.split(',');
            final progress = double.parse(parts[0]); // sec
            final mode = int.parse(parts[1]);
            final fontsize = int.parse(parts[2]);
            final color = int.parse(parts[3]);
            // final ctime = int.parse(parts[4]);
            // final pool = int.parse(parts[5]);
            final midHash = parts[6];
            final id = int.parse(parts[7]);
            final weight = int.parse(parts[8]);
            final content = dm.innerText;
            elems.add(
              DanmakuElem(
                progress: (progress * 1000).toInt(),
                mode: mode,
                fontsize: fontsize,
                color: color,
                midHash: midHash,
                id: Int64(id),
                weight: weight,
                content: content,
              ),
            );
          }
        } catch (_) {
          if (kDebugMode) rethrow;
        }
      }
      handleDanmaku(elems);
    } catch (_) {
      if (kDebugMode) rethrow;
    }
  }
}
