# Money Asset Management

本项目是一个纯 Flutter 原生的 Android 资产管理应用，用于记录和维护个人资产、分类、生命周期事件、本地备份与提醒设置。

所有核心数据默认保存在本机 SQLite 中，不依赖在线账户或云端服务。

## 下载

- GitHub Releases: [Money Assets 2.1.0.1](https://github.com/SANQking/Money-Asset-management/releases/tag/v2.1.0.1)
- APK: [money-assets-2.1.0.1-release.apk](https://github.com/SANQking/Money-Asset-management/releases/download/v2.1.0.1/money-assets-2.1.0.1-release.apk)
- SHA256: `f1d8606a7da4cab22a6dc7b0bc451eb3f9296db3a2f80ba5ce878f7bad50bc03`

## 当前版本

- App version: `2.1.0.1`
- Flutter version field: `2.1.0+1`
- Android package: `com.grzcgl.mobile`

## 主要功能

- 原生 Dashboard 仪表盘
  - 资产数量
  - 原值、当前估值、折旧、日均成本
  - 提醒概览
  - 分类价值排行
  - 真实成本排行
- 原生资产列表
  - 搜索
  - 分类、状态、价格、时间、提醒、价值状态筛选
  - 资产缩略图
  - 日均成本和使用天数展示
- 资产写操作
  - 新增资产
  - 编辑资产
  - 删除资产
  - 生命周期事件新增、删除
  - 相册选图、压缩、预览
- 设置中心
  - 主题切换
  - 数字显示设置
  - 数据管理
  - 分类管理
  - 资产提醒
- 数据管理
  - 手动备份资产数据
  - 清空资产数据
  - 备份查看、恢复、删除
- 本地通知
  - 保修提醒
  - 长期闲置提醒
  - 保养周期提醒

## 主题系统

应用内置三套原生主题，并支持即时切换与本地持久化：

- `minimal`
  - 白底
  - 黑字
  - 灰色辅助信息
  - 无物理边框
- `blackGold`
  - 深色背景
  - 金色强调
- `pink`
  - 浅粉背景
  - 圆润控件
  - 柔和投影

## 技术栈

- Flutter
- Dart
- Drift
- SQLite
- image_picker
- image
- flutter_local_notifications
- timezone

## 项目结构

- [lib/main.dart](lib/main.dart)
  - 应用入口
- [lib/app/native_asset_app_shell.dart](lib/app/native_asset_app_shell.dart)
  - 原生底部导航 Shell
- [lib/features/dashboard/dashboard_page.dart](lib/features/dashboard/dashboard_page.dart)
  - 仪表盘页面
- [lib/features/assets/asset_list_page.dart](lib/features/assets/asset_list_page.dart)
  - 资产列表与资产表单
- [lib/features/settings/settings_page.dart](lib/features/settings/settings_page.dart)
  - 设置中心
- [lib/features/migration/data_migration_page.dart](lib/features/migration/data_migration_page.dart)
  - 数据管理区块
- [lib/data/local/app_database.dart](lib/data/local/app_database.dart)
  - Drift 数据库定义
- [test/widget_test.dart](test/widget_test.dart)
  - 基础入口测试

## 数据说明

- 所有业务数据默认保存在本机 SQLite
- 当前不依赖 WebView 运行时
- 当前不保留旧版 HTML 入口
- 备份数据保存在本地数据库备份记录中
- 金额显示支持小数位设置，但不会改变原始存储精度

## 本地开发

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## 构建

调试包：

```bash
flutter build apk --debug
```

发布包：

```bash
flutter build apk --release
```

输出路径：

```text
build/app/outputs/flutter-apk/
```

仓库内同步的发布包：

```text
dist/money-assets-2.1.0.1-release.apk
```

## Release 说明

当前仓库的 Release 附件中包含：

- Android APK
- SHA256 校验文件

Release 页面：

- [https://github.com/SANQking/Money-Asset-management/releases](https://github.com/SANQking/Money-Asset-management/releases)

## 备注

- 当前 APK 使用可安装签名构建，便于真机直接安装测试
- 若后续用于正式分发或商店发布，建议切换到专用 release keystore
