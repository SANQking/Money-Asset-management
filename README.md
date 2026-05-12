# Money

Money 是一个本地优先的个人资产管理 Android 应用，用来记录和管理个人资产、估值、保修到期、闲置情况、维修保养以及完整生命周期。

这个项目采用 Flutter + Android WebView 结构：Flutter 负责原生应用外壳与系统能力接入，实际业务界面运行在内置的单页 Web 应用中。所有核心数据默认保存在本机，不依赖在线账户。

## 这个项目是什么

Money 面向需要长期记录个人物品和资产状态的用户，适合管理：

- 数码设备
- 家电
- 家具
- 交通工具相关资产
- 收藏物品
- 证件与其它个人资产

它不只是一个简单清单，而是围绕“购买、使用、折旧、维修、保养、出售、报废”这一整条生命周期来管理资产。

## 主要功能

- 资产仪表盘总览
- 原价、当前估值、折旧、真实成本统计
- 生命周期事件记录，例如购买、维修、保养、估值、出售、报废
- 资产图片选择与展示
- 分类与颜色管理
- 主题切换
- 本地备份、恢复、JSON/CSV 导入导出
- 中英文界面切换

## 技术栈

- Flutter
- Android
- webview_flutter
- 内置 HTML / CSS / JavaScript 单页应用

## 项目结构

- [lib/main.dart](lib/main.dart) - Flutter 启动壳、WebView 容器、文件选择
- [assets/web/index.html](assets/web/index.html) - 主界面、业务逻辑、数据存储与中英文切换
- [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) - Android 应用配置
- [test/widget_test.dart](test/widget_test.dart) - Flutter 壳层测试

## 本地开发

```bash
flutter pub get
flutter run
```

## 构建 APK

```bash
flutter build apk --release
```

release APK 输出位置：

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 数据说明

- 应用数据默认保存在本机
- 不依赖在线后端
- 备份、恢复与导入导出功能都围绕本地数据工作

## 下载 APK

建议优先从 GitHub Releases 页面下载 APK，而不是直接从源码目录查找构建产物。
