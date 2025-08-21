import 'dart:async';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models_new/fav/fav_folder/list.dart';
import 'package:PiliPlus/pages/common/common_page.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/media/controller.dart';
import 'package:PiliPlus/pages/media/widgets/item.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaPage extends CommonPage {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends CommonPageState<MediaPage, MediaController>
    with AutomaticKeepAliveClientMixin {
  @override
  MediaController controller = Get.put(MediaController());
  late final MainController _mainController = Get.find<MainController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void listener() {
    if (_mainController.navigationBars[0] != NavigationBarType.media &&
        _mainController.selectedIndex.value == 0) {
      return;
    }
    super.listener();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    Color primary = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Material(
        type: MaterialType.transparency,
        child: ListView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ListTile(
              leading: null,
              title: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  '[ 媒体库 ]',
                  style: TextStyle(
                    fontSize: theme.textTheme.titleLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: IconButton(
                tooltip: '设置',
                onPressed: () => Get.toNamed('/setting'),
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (var item in controller.list)
              ListTile(
                onTap: item.onTap,
                dense: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Icon(
                    item.icon,
                    color: primary,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.only(left: 15, top: 2, bottom: 2),
                minLeadingWidth: 0,
                title: Text(
                  item.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            Obx(
              () => controller.loadingState.value is Loading
                  ? const SizedBox.shrink()
                  : favFolder(theme),
            )
          ],
        ),
      ),
    );
  }

  Widget favFolder(ThemeData theme) {
    return Column(
      children: [
        Divider(
          height: 20,
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        ListTile(
          onTap: () async {
            await Get.toNamed('/fav');
            Future.delayed(const Duration(milliseconds: 150), () {
              controller.onRefresh();
            });
          },
          dense: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Obx(
              () => Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '我的收藏  ',
                      style: TextStyle(
                          fontSize: theme.textTheme.titleMedium!.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    if (controller.count.value != -1)
                      TextSpan(
                        text: "${controller.count.value}  ",
                        style: TextStyle(
                          fontSize: theme.textTheme.titleSmall!.fontSize,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    WidgetSpan(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          trailing: IconButton(
            tooltip: '刷新',
            onPressed: controller.onRefresh,
            icon: const Icon(Icons.refresh, size: 20),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Obx(() => _buildBody(theme, controller.loadingState.value)),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:var response) => Builder(
          builder: (context) {
            List<FavFolderInfo>? favFolderList = response.list;
            if (favFolderList.isNullOrEmpty) {
              return const SizedBox.shrink();
            }
            bool flag = controller.count.value > favFolderList!.length;
            return ListView.separated(
              padding: const EdgeInsets.only(left: 20),
              itemCount: response.list.length + (flag ? 1 : 0),
              itemBuilder: (context, index) {
                if (flag && index == favFolderList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14, bottom: 35),
                    child: Center(
                      child: IconButton(
                        tooltip: '查看更多',
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            return theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5);
                          }),
                        ),
                        onPressed: () async {
                          await Get.toNamed('/fav');
                          Future.delayed(const Duration(milliseconds: 150), () {
                            controller.onRefresh();
                          });
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                } else {
                  return FavFolderItem(
                    heroTag: Utils.generateRandomString(8),
                    item: response.list[index],
                    callback: () => Future.delayed(
                      const Duration(milliseconds: 150),
                      controller.onRefresh,
                    ),
                  );
                }
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
            );
          },
        ),
      Error(:var errMsg) => SizedBox(
          height: 160,
          child: Center(
            child: Text(
              errMsg ?? '',
              textAlign: TextAlign.center,
            ),
          ),
        ),
    };
  }
}
