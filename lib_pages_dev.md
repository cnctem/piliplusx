# PiliPlus 页面开发文档

## 概述

本文档详细介绍了 PiliPlus 应用中 `lib/pages/` 目录下的所有页面组件，包括页面结构、功能特性、开发规范和最佳实践。

## 页面架构

### 目录结构

```
lib/pages/
├── main/                     # 主应用页面
├── home/                     # 首页推荐
├── video/                    # 视频播放页面 (核心功能)
├── live/                     # 直播功能
├── dynamics/                 # 动态功能
├── member/                   # 用户主页
├── search/                   # 搜索功能
├── setting/                  # 设置页面
├── fav/                      # 收藏功能
├── history/                  # 历史记录
├── later/                    # 稍后再看
├── login/                    # 登录功能
├── whisper/                  # 私信功能
├── webdav/                   # WebDAV 功能
├── webview/                  # 网页视图
├── about/                    # 关于页面
└── [其他功能页面...]
```

### 页面组织模式

每个页面通常包含以下文件：
- `view.dart` - 页面视图组件
- `controller.dart` - 页面控制器 (GetX)
- `widgets/` - 页面专用组件
- `models/` - 页面数据模型

## 核心页面详解

### 1. 主应用页面 (main/)

**文件结构：**
- `view.dart` (18KB, 459行) - 主应用视图
- `controller.dart` (6.3KB, 219行) - 主应用控制器

**功能特性：**
- 底部导航栏管理
- 页面路由控制
- 应用生命周期管理
- 未读消息检查
- 搜索默认词更新
- 横竖屏适配

**关键组件：**
```dart
class MainApp extends StatefulWidget {
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
}

class _MainAppState extends State<MainApp> with RouteAware, WidgetsBindingObserver {
  // 生命周期管理
  // 导航控制
  // 状态管理
}
```

### 2. 视频播放页面 (video/)

**文件结构：**
- `view.dart` (88KB, 2220行) - 视频播放视图
- `controller.dart` (56KB, 1661行) - 视频播放控制器
- `widgets/` - 视频相关组件
- `reply/` - 评论功能
- `related/` - 相关视频
- `introduction/` - 视频介绍

**功能特性：**
- 视频播放器集成
- 弹幕显示和发送
- 评论系统
- 相关视频推荐
- 视频信息展示
- 播放控制
- 全屏支持
- 画中画模式

**子模块：**
- `reply/` - 评论回复系统
- `reply_reply/` - 评论的回复
- `reply_new/` - 新版评论
- `reply_search_item/` - 评论搜索项
- `send_danmaku/` - 发送弹幕
- `view_point/` - 观点展示
- `related/` - 相关视频
- `introduction/` - 视频介绍
- `member/` - 用户信息
- `medialist/` - 媒体列表
- `note/` - 笔记功能
- `pay_coins/` - 投币功能
- `ai_conclusion/` - AI 总结

### 3. 首页推荐 (home/)

**文件结构：**
- `view.dart` (9.4KB, 278行) - 首页视图
- `controller.dart` (2.7KB, 105行) - 首页控制器

**功能特性：**
- 推荐视频流
- 搜索默认词
- 内容刷新
- 无限滚动

### 4. 直播功能 (live/)

**文件结构：**
- `view.dart` (12KB, 326行) - 直播视图
- `controller.dart` (3.5KB, 144行) - 直播控制器
- `widgets/` - 直播组件

**功能特性：**
- 直播列表展示
- 直播分区浏览
- 直播搜索
- 关注主播

**相关页面：**
- `live_area/` - 直播分区
- `live_area_detail/` - 分区详情
- `live_room/` - 直播间
- `live_search/` - 直播搜索
- `live_follow/` - 关注直播
- `live_emote/` - 直播表情
- `live_dm_block/` - 直播弹幕屏蔽

### 5. 动态功能 (dynamics/)

**文件结构：**
- `view.dart` (6.1KB, 181行) - 动态视图
- `controller.dart` (5.8KB, 215行) - 动态控制器
- `widgets/` - 动态组件

**功能特性：**
- 动态流展示
- 动态发布
- 动态互动
- 话题管理

**相关页面：**
- `dynamics_create/` - 发布动态
- `dynamics_create_vote/` - 发布投票
- `dynamics_create_reserve/` - 定时发布
- `dynamics_detail/` - 动态详情
- `dynamics_topic/` - 话题页面
- `dynamics_topic_rcmd/` - 话题推荐
- `dynamics_repost/` - 转发动态
- `dynamics_select_topic/` - 选择话题
- `dynamics_mention/` - 提及用户
- `dynamics_tab/` - 动态标签页

### 6. 用户主页 (member/)

**文件结构：**
- `view.dart` (13KB, 366行) - 用户主页视图
- `controller.dart` (7.2KB, 265行) - 用户主页控制器
- `widget/` - 用户主页组件

**功能特性：**
- 用户信息展示
- 用户作品列表
- 用户统计信息
- 关注/粉丝管理

**相关页面：**
- `member_profile/` - 用户资料
- `member_dynamics/` - 用户动态
- `member_video/` - 用户视频
- `member_opus/` - 用户作品
- `member_article/` - 用户文章
- `member_audio/` - 用户音频
- `member_comic/` - 用户漫画
- `member_contribute/` - 用户投稿
- `member_favorite/` - 用户收藏
- `member_like_arc/` - 用户点赞
- `member_coin_arc/` - 用户投币
- `member_season_series/` - 用户剧集
- `member_pgc/` - 用户PGC内容
- `member_search/` - 用户搜索
- `member_upower_rank/` - 用户排行榜

### 7. 搜索功能 (search/)

**文件结构：**
- `view.dart` (14KB, 380行) - 搜索视图
- `controller.dart` (4.8KB, 195行) - 搜索控制器
- `widgets/` - 搜索组件

**功能特性：**
- 多类型搜索
- 搜索历史
- 搜索建议
- 搜索结果展示

**相关页面：**
- `search_result/` - 搜索结果
- `search_trending/` - 搜索趋势
- `search_panel/` - 搜索面板
- `settings_search/` - 设置搜索

### 8. 设置页面 (setting/)

**文件结构：**
- `view.dart` (11KB, 318行) - 设置主视图
- `pages/` - 设置子页面
- `widgets/` - 设置组件
- `models/` - 设置数据模型

**功能特性：**
- 应用设置管理
- 主题设置
- 播放设置
- 隐私设置

**设置子页面：**
- `pages/logs.dart` - 日志查看
- `pages/play_speed_set.dart` - 播放速度设置
- `pages/bar_set.dart` - 导航栏设置
- `pages/color_select.dart` - 颜色选择
- `pages/display_mode.dart` - 显示模式
- `pages/font_size_select.dart` - 字体大小

**设置分类：**
- `style_setting.dart` - 样式设置
- `video_setting.dart` - 视频设置
- `play_setting.dart` - 播放设置
- `privacy_setting.dart` - 隐私设置
- `recommend_setting.dart` - 推荐设置
- `extra_setting.dart` - 额外设置

### 9. 收藏功能 (fav/)

**文件结构：**
- `view.dart` (5.6KB, 162行) - 收藏主视图
- `video/` - 收藏视频
- `pgc/` - 收藏PGC
- `topic/` - 收藏话题
- `note/` - 收藏笔记
- `article/` - 收藏文章

**功能特性：**
- 收藏夹管理
- 多类型内容收藏
- 收藏分类
- 收藏搜索

**相关页面：**
- `fav_detail/` - 收藏详情
- `fav_create/` - 创建收藏夹
- `fav_panel/` - 收藏面板
- `fav_search/` - 收藏搜索
- `fav_sort/` - 收藏排序
- `fav_folder_sort/` - 收藏夹排序

### 10. 历史记录 (history/)

**文件结构：**
- `view.dart` - 历史记录视图
- `controller.dart` - 历史记录控制器

**功能特性：**
- 观看历史
- 历史搜索
- 历史管理

**相关页面：**
- `history_search/` - 历史搜索

### 11. 稍后再看 (later/)

**文件结构：**
- `view.dart` - 稍后再看视图
- `controller.dart` - 稍后再看控制器

**功能特性：**
- 稍后再看列表
- 稍后再看搜索
- 稍后再看管理

**相关页面：**
- `later_search/` - 稍后再看搜索

### 12. 登录功能 (login/)

**文件结构：**
- `view.dart` - 登录视图
- `controller.dart` - 登录控制器

**功能特性：**
- 用户登录
- 登录日志
- 账户管理

**相关页面：**
- `login_log/` - 登录日志

### 13. 私信功能 (whisper/)

**文件结构：**
- `view.dart` (6.5KB, 192行) - 私信视图
- `controller.dart` (2.9KB, 101行) - 私信控制器
- `widgets/` - 私信组件

**功能特性：**
- 私信列表
- 私信详情
- 私信设置
- 私信屏蔽

**相关页面：**
- `whisper_detail/` - 私信详情
- `whisper_settings/` - 私信设置
- `whisper_link_setting/` - 私信链接设置
- `whisper_secondary/` - 私信二级页面
- `whisper_block/` - 私信屏蔽

### 14. 消息中心 (msg_feed_top/)

**功能特性：**
- 消息通知
- 回复消息
- 点赞消息
- 系统消息

**子页面：**
- `reply_me/` - 回复我的
- `like_me/` - 点赞我的
- `like_detail/` - 点赞详情
- `at_me/` - @我的
- `sys_msg/` - 系统消息

### 15. 其他功能页面

#### 内容相关
- `article/` - 文章阅读
- `article_list/` - 文章列表
- `pgc/` - PGC内容
- `pgc_index/` - PGC索引
- `pgc_review/` - PGC评论
- `rank/` - 排行榜
- `rcmd/` - 推荐内容

#### 互动功能
- `follow/` - 关注功能
- `follow_search/` - 关注搜索
- `fan/` - 粉丝功能
- `contact/` - 联系功能

#### 管理功能
- `blacklist/` - 黑名单
- `danmaku_block/` - 弹幕屏蔽
- `sponsor_block/` - 赞助商屏蔽
- `emote/` - 表情管理

#### 工具功能
- `webdav/` - WebDAV管理
- `webview/` - 网页视图
- `share/` - 分享功能
- `save_panel/` - 保存面板
- `group_panel/` - 分组面板
- `episode_panel/` - 剧集面板

#### 系统功能
- `about/` - 关于页面
- `space_setting/` - 空间设置
- `exp_log/` - 经验日志
- `coin_log/` - 硬币日志

## 页面开发规范

### 1. 文件命名规范

- 页面目录使用小写字母和下划线
- 视图文件命名为 `view.dart`
- 控制器文件命名为 `controller.dart`
- 组件目录命名为 `widgets/` 或 `widget/`

### 2. 代码组织规范

```dart
// 标准页面结构
class PageName extends StatefulWidget {
  const PageName({super.key});
  
  @override
  State<PageName> createState() => _PageNameState();
}

class _PageNameState extends State<PageName> {
  late final PageController _controller = Get.put(PageController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面内容
    );
  }
}
```

### 3. GetX 状态管理

- 使用 GetX 进行状态管理
- 控制器继承自 `GetxController`
- 使用响应式变量进行状态更新
- 合理使用依赖注入

### 4. 页面路由

- 在 `router/app_pages.dart` 中定义路由
- 使用命名路由进行页面跳转
- 支持路由参数传递

### 5. 组件复用

- 公共组件放在 `common/widgets/`
- 页面专用组件放在页面目录下的 `widgets/`
- 组件应该具有良好的封装性

### 6. 性能优化

- 使用 `const` 构造函数
- 合理使用 `ListView.builder`
- 图片懒加载
- 避免不必要的重建

## 页面开发最佳实践

### 1. 响应式设计

- 支持横竖屏切换
- 适配不同屏幕尺寸
- 使用 `MediaQuery` 获取屏幕信息

### 2. 用户体验

- 提供加载状态
- 错误处理和重试机制
- 空状态展示
- 流畅的动画效果

### 3. 数据管理

- 合理的数据缓存策略
- 网络请求错误处理
- 数据刷新机制
- 本地存储管理

### 4. 测试和调试

- 页面功能测试
- 性能监控
- 内存泄漏检测
- 异常捕获

## 页面开发工具

### 1. 开发环境

- Flutter SDK
- Dart SDK
- IDE (Android Studio / VS Code)
- 调试工具

### 2. 调试工具

- Flutter Inspector
- Performance Overlay
- Debug Console
- Network Inspector

### 3. 测试工具

- Flutter Test
- Integration Test
- Widget Test
- Mockito (模拟测试)

## 总结

PiliPlus 的页面架构采用了模块化、组件化的设计理念，通过 GetX 状态管理框架实现了高效的页面开发。每个页面都有清晰的职责分工，代码结构规范，便于维护和扩展。

开发者可以根据本文档了解各个页面的功能特性，遵循开发规范，快速上手页面开发工作。

---

*本文档基于 lib/pages/ 目录下的实际代码结构编写，反映了 PiliPlus 项目的页面架构和开发模式。* 