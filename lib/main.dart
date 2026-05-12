import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

const _appBackgroundColor = Color(0xFFF4EAD8);

void main() {
  runApp(const GrzcglApp());
}

class GrzcglApp extends StatelessWidget {
  const GrzcglApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money-个人资产管理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: _appBackgroundColor),
      home: const AssetManagerShell(),
    );
  }
}

class AssetManagerShell extends StatefulWidget {
  const AssetManagerShell({super.key});

  @override
  State<AssetManagerShell> createState() => _AssetManagerShellState();
}

class _AssetManagerShellState extends State<AssetManagerShell> {
  late final WebViewController _controller;
  var _pageReady = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF4EAD8))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _pageReady = true);
            }
          },
          onNavigationRequest: (request) =>
              _isAllowedLocalNavigation(request.url)
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
        ),
      );

    final platformController = _controller.platform;
    if (platformController is AndroidWebViewController) {
      platformController.setOnShowFileSelector(_pickImageFile);
    }

    _controller.loadFlutterAsset('assets/web/index.html');
  }

  bool _isAllowedLocalNavigation(String url) {
    if (url == 'about:blank') return true;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (uri.scheme == 'file') {
      return uri.path.startsWith('/android_asset/flutter_assets/assets/web/');
    }
    return uri.scheme == 'https' &&
        uri.host == 'appassets.androidplatform.net' &&
        uri.path.startsWith('/assets/web/');
  }

  Future<List<String>> _pickImageFile(FileSelectorParams params) async {
    final acceptedTypes = params.acceptTypes
        .expand((type) => type.split(','))
        .map((type) => type.trim())
        .where((type) => type.isNotEmpty && type != '*/*');
    final mimeTypes = acceptedTypes.any((type) => type.contains('/'))
        ? acceptedTypes.where((type) => type.contains('/')).toList()
        : <String>['image/*'];
    final typeGroups = <XTypeGroup>[
      XTypeGroup(label: '图片', mimeTypes: mimeTypes),
    ];

    if (params.mode == FileSelectorMode.openMultiple) {
      final files = await openFiles(acceptedTypeGroups: typeGroups);
      return files.map((file) => Uri.file(file.path).toString()).toList();
    }

    final file = await openFile(acceptedTypeGroups: typeGroups);
    return file == null ? <String>[] : <String>[Uri.file(file.path).toString()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(child: WebViewWidget(controller: _controller)),
          if (!_pageReady) const _StartupShell(),
        ],
      ),
    );
  }
}

class _StartupShell extends StatelessWidget {
  const _StartupShell();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: _appBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Money 个人资产管理',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF24190F),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '正在打开本机资产数据...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF7B6247),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
