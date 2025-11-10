import 'dart:async';

import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/pages/download/controller.dart';
import 'package:PiliPlus/pages/download/detail/widgets/item.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadDetailPage extends StatefulWidget {
  const DownloadDetailPage({
    super.key,
    required this.pageId,
    required this.title,
    required this.progress,
  });

  final String pageId;
  final String title;
  final ValueNotifier progress;

  @override
  State<DownloadDetailPage> createState() => _DownloadDetailPageState();
}

class _DownloadDetailPageState extends State<DownloadDetailPage>
    with GridMixin {
  StreamSubscription? _sub;
  final _downloadItems = RxList<BiliDownloadEntryInfo>();
  final _controller = Get.find<DownloadPageController>();
  final _downloadService = Get.find<DownloadService>();

  @override
  void initState() {
    super.initState();
    _loadList();
    _sub = _controller.flag.listen((_) {
      _loadList();
    });
  }

  Future _closeSub() async {
    if (_sub != null) {
      await _sub?.cancel();
      _sub = null;
    }
  }

  @override
  void dispose() {
    _closeSub();
    super.dispose();
  }

  void _loadList() {
    final list =
        _controller.pages
            .firstWhereOrNull((e) => e.pageId == widget.pageId)
            ?.entrys
          ?..sort((a, b) => a.sortKey.compareTo(b.sortKey));
    if (list != null) {
      _downloadItems.value = list;
    } else {
      _downloadItems.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: CustomScrollView(
        slivers: [
          ViewSliverSafeArea(
            sliver: Obx(() {
              if (_downloadItems.isNotEmpty) {
                return SliverGrid.builder(
                  gridDelegate: gridDelegate,
                  itemBuilder: (context, index) {
                    final entry = _downloadItems[index];
                    return DetailItem(
                      entry: entry,
                      progress: widget.progress,
                      downloadService: _downloadService,
                      showTitle: false,
                      onDelete: () async {
                        if (_downloadItems.length == 1) {
                          await _closeSub();
                          await _downloadService.deletePage(
                            pageDirPath: entry.pageDirPath,
                          );
                          if (context.mounted) {
                            Get.back();
                          }
                        } else {
                          _downloadService.deleteDownload(entry: entry);
                        }
                        GStorage.watchProgress.delete(entry.cid.toString());
                      },
                    );
                  },
                  itemCount: _downloadItems.length,
                );
              }
              return const HttpError();
            }),
          ),
        ],
      ),
    );
  }
}
