import 'dart:async';

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models_new/download/download_info.dart';
import 'package:PiliPlus/pages/download/controller.dart';
import 'package:PiliPlus/pages/download/detail/view.dart';
import 'package:PiliPlus/pages/download/detail/widgets/item.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with GridMixin {
  final _downloadService = Get.find<DownloadService>();
  final _controller = Get.put(DownloadPageController());
  final _progress = ValueNotifier(null);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('离线缓存')),
      body: CustomScrollView(
        slivers: [
          ViewSliverSafeArea(
            sliver: Obx(() {
              if (_controller.pages.isNotEmpty) {
                return SliverGrid.builder(
                  gridDelegate: gridDelegate,
                  itemBuilder: (context, index) {
                    final item = _controller.pages[index];
                    if (item.entrys.length == 1) {
                      final entry = item.entrys.first;
                      return DetailItem(
                        entry: entry,
                        progress: _progress,
                        downloadService: _downloadService,
                        showTitle: true,
                        onDelete: () {
                          _downloadService.deleteDownload(entry: entry);
                          GStorage.watchProgress.delete(entry.cid.toString());
                        },
                      );
                    }
                    return _buildItem(theme, item);
                  },
                  itemCount: _controller.pages.length,
                );
              }
              return const HttpError();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(ThemeData theme, DownloadPageInfo pageInfo) {
    final outline = theme.colorScheme.outline;
    final entry = pageInfo.entry;
    final isCompleted = entry == null;
    void onLongPress() => isCompleted
        ? showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                clipBehavior: Clip.hardEdge,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () {
                        Get.back();
                        showConfirmDialog(
                          context: context,
                          title: '确定删除？',
                          onConfirm: () async {
                            final watchProgress = GStorage.watchProgress;
                            await Future.wait(
                              pageInfo.entrys.map((e) {
                                final cid = e.pageData?.cid ?? e.source?.cid;
                                return watchProgress.delete(cid.toString());
                              }),
                            );
                            _downloadService.deletePage(
                              pageDirPath: pageInfo.dirPath,
                            );
                          },
                        );
                      },
                      dense: true,
                      title: const Text(
                        '删除',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        Get.back();
                        final res = await Future.wait(
                          pageInfo.entrys.map(
                            (e) => _downloadService.downloadDanmaku(
                              entry: e,
                              isUpdate: true,
                            ),
                          ),
                        );
                        if (res.every((e) => e)) {
                          SmartDialog.showToast('更新成功');
                        } else {
                          SmartDialog.showToast('更新失败');
                        }
                      },
                      dense: true,
                      title: const Text(
                        '更新弹幕',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : null;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => Get.to(
          DownloadDetailPage(
            pageId: pageInfo.pageId,
            title: pageInfo.title,
            progress: _progress,
          ),
        ),
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StyleString.safeSpace,
            vertical: 5,
          ),
          child: Row(
            spacing: 10,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, constraints) => NetworkImgLayer(
                        src: pageInfo.cover,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                    ),
                  ),
                  PBadge(
                    text: '${pageInfo.entrys.length}个视频',
                    right: 6.0,
                    bottom: 6.0,
                    isBold: false,
                    type: PBadgeType.gray,
                  ),
                  if (pageInfo.seasonType case final pgcType?)
                    PBadge(
                      text: switch (pgcType) {
                        -1 => '课程',
                        1 => '番剧',
                        2 => '电影',
                        3 => '纪录片',
                        4 => '国创',
                        5 => '电视剧',
                        7 => '综艺',
                        _ => null,
                      },
                      right: 6.0,
                      top: 6.0,
                    ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pageInfo.title,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: theme.textTheme.bodyMedium!.fontSize,
                          height: 1.42,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted)
                      Text(
                        '已完成',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1,
                          color: outline,
                        ),
                      )
                    else
                      entry.progressWidget(
                        theme: theme,
                        downloadService: _downloadService,
                        isPage: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
