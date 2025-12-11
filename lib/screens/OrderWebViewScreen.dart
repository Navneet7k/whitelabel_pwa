import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zing_whitelabel_revamp/constants.dart';

import '../storage_service.dart';

class OrderWebViewScreen extends StatefulWidget {
  final String slug;
  const OrderWebViewScreen({required this.slug});

  @override
  State<OrderWebViewScreen> createState() => _OrderWebViewScreenState();
}

class _OrderWebViewScreenState extends State<OrderWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final token = await StorageService.getToken();
    final uri = Uri.parse("${Constants.webBaseUrl1}/${widget.slug}?token=$token");

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.contains("login-as/client")) {
              Navigator.of(context).pop('goToAccount');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(uri);

    if (mounted) setState(() {}); // ensure widget rebuilds after controller is ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Order"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_isLoading)
            Container(
              color: Colors.white, // This ensures the background (including padding) is white
              padding: const EdgeInsets.only(bottom: 60.0), // Adds bottom space
              child: WebViewWidget(controller: _controller),
            ),
          if (_isLoading)
            const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

