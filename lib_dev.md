# PiliPlus 开发文档

## 项目概述

PiliPlus 是一个基于 Flutter 开发的 B站第三方客户端应用，采用 GetX 状态管理框架，支持视频播放、直播、动态、收藏等功能。

## 项目结构

### 核心文件

- `main.dart` - 应用程序入口点，负责初始化配置、主题设置、路由配置等
- `build_config.dart` - 构建配置信息，包含构建时间和提交哈希

### 目录结构

```
lib/
├── main.dart                 # 应用入口
├── build_config.dart         # 构建配置
├── pages/                    # 页面组件
├── services/                 # 服务层
├── models/                   # 数据模型
├── utils/                    # 工具类
├── http/                     # 网络请求
├── router/                   # 路由配置
├── common/                   # 公共组件
├── tcp/                      # TCP 相关
├── grpc/                     # gRPC 相关
├── plugin/                   # 插件
└── scripts/                  # 脚本
```

## 主要模块

### 1. 页面模块 (pages/)

包含应用的所有页面组件，按功能分类：

#### 核心页面
- `main/` - 主应用页面
- `home/` - 首页推荐
- `video/` - 视频播放页面
- `search/` - 搜索功能
- `setting/` - 设置页面

#### 用户相关
- `login/` - 登录页面
- `member/` - 用户主页
- `member_profile/` - 用户资料
- `member_dynamics/` - 用户动态

#### 内容功能
- `fav/` - 收藏功能
- `history/` - 历史记录
- `later/` - 稍后再看
- `dynamics/` - 动态功能
- `live/` - 直播功能

#### 其他功能
- `whisper/` - 私信功能
- `webdav/` - WebDAV 功能
- `webview/` - 网页视图
- `about/` - 关于页面

### 2. 服务层 (services/)

负责应用的核心服务：

- `service_locator.dart` - 服务定位器，管理全局服务实例
- `account_service.dart` - 账户服务
- `audio_handler.dart` - 音频处理服务
- `audio_session.dart` - 音频会话管理
- `shutdown_timer_service.dart` - 关机定时器服务
- `loggeer.dart` - 日志服务

### 3. 数据模型 (models/)

定义应用的数据结构：

#### 用户模型 (user/)
- `info.dart` - 用户信息模型
- `stat.dart` - 用户统计信息
- `danmaku_block.dart` - 弹幕屏蔽规则
- `danmaku_rule.dart` - 弹幕规则

#### 视频模型 (video/)
- 视频播放相关数据模型

#### 其他模型
- `common/` - 通用模型
- `dynamics/` - 动态相关模型
- `home/` - 首页相关模型
- `login/` - 登录相关模型
- `search/` - 搜索相关模型

### 4. 工具类 (utils/)

提供各种工具函数：

#### 核心工具
- `storage_pref.dart` - 偏好设置存储 (26KB)
- `page_utils.dart` - 页面工具 (25KB)
- `request_utils.dart` - 请求工具 (22KB)
- `app_scheme.dart` - 应用协议处理 (29KB)

#### 功能工具
- `theme_utils.dart` - 主题工具
- `image_util.dart` - 图片处理
- `video_utils.dart` - 视频工具
- `date_util.dart` - 日期工具
- `cache_manage.dart` - 缓存管理
- `login_utils.dart` - 登录工具

#### 其他工具
- `storage.dart` - 存储工具
- `storage_key.dart` - 存储键定义
- `url_utils.dart` - URL 工具
- `wbi_sign.dart` - WBI 签名
- `danmaku_utils.dart` - 弹幕工具

### 5. 网络请求 (http/)

处理所有网络通信：

#### 核心 API
- `api.dart` - 主要 API 接口 (33KB)
- `init.dart` - HTTP 初始化配置

#### 功能模块
- `video.dart` - 视频相关 API (26KB)
- `member.dart` - 用户相关 API (20KB)
- `dynamics.dart` - 动态相关 API (17KB)
- `fav.dart` - 收藏相关 API (18KB)
- `msg.dart` - 消息相关 API (16KB)
- `live.dart` - 直播相关 API (15KB)
- `login.dart` - 登录相关 API (14KB)
- `user.dart` - 用户 API (12KB)
- `search.dart` - 搜索 API
- `pgc.dart` - PGC 内容 API
- `reply.dart` - 回复相关 API

#### 其他
- `danmaku.dart` - 弹幕 API
- `danmaku_block.dart` - 弹幕屏蔽 API
- `constants.dart` - API 常量
- `retry_interceptor.dart` - 重试拦截器

### 6. 路由配置 (router/)

- `app_pages.dart` - 应用路由配置，定义所有页面路由

## 技术栈

### 状态管理
- **GetX** - 主要状态管理框架
- 支持响应式编程和依赖注入

### UI 框架
- **Flutter** - 跨平台 UI 框架
- **Material Design** - 设计语言
- **Dynamic Color** - 动态颜色支持
- **Flex Seed Scheme** - 主题色方案

### 网络通信
- **HTTP/HTTPS** - 标准网络协议
- **gRPC** - 高性能 RPC 框架
- **TCP** - 底层网络通信

### 媒体播放
- **MediaKit** - 跨平台媒体播放器
- 支持视频、音频播放

### 其他技术
- **Catcher2** - 异常捕获和日志记录
- **Flutter Smart Dialog** - 智能对话框
- **Flutter Localizations** - 国际化支持

## 主要功能

### 1. 视频功能
- 视频播放和暂停
- 弹幕显示和发送
- 视频收藏和点赞
- 播放历史记录
- 稍后再看功能

### 2. 直播功能
- 直播观看
- 弹幕互动
- 直播分区浏览
- 关注主播

### 3. 用户功能
- 用户登录和注册
- 个人资料管理
- 动态发布和浏览
- 私信功能

### 4. 内容管理
- 视频搜索
- 收藏夹管理
- 历史记录
- 推荐算法

### 5. 设置功能
- 主题切换
- 播放设置
- 隐私设置
- 缓存管理

## 开发指南

### 环境要求
- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- 相关依赖包

### 构建配置
项目使用 `build_config.dart` 管理构建信息：
- 构建时间戳
- Git 提交哈希
- 版本信息

### 代码规范
- 遵循 Dart 代码规范
- 使用 GetX 状态管理模式
- 模块化设计
- 清晰的目录结构

### 调试和测试
- 支持调试模式
- 异常捕获和日志记录
- 性能监控

## 部署和发布

### 构建流程
1. 更新 `build_config.dart` 中的构建信息
2. 运行 Flutter 构建命令
3. 生成 APK/IPA 文件

### 发布注意事项
- 确保所有依赖正确配置
- 测试各项功能正常
- 检查性能和内存使用
- 遵循应用商店规范

## 维护和支持

### 日志管理
- 使用 Catcher2 进行异常捕获
- 支持文件和控制台日志输出
- 可配置日志级别

### 更新机制
- 支持应用内更新
- 版本检查和提示
- 自动更新功能

### 问题反馈
- 异常报告机制
- 用户反馈收集
- 问题跟踪和解决

---

*本文档基于 lib 目录下的实际代码结构编写，反映了 PiliPlus 项目的当前架构和功能特性。*
