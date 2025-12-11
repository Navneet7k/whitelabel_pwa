import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zing_whitelabel_revamp/constants.dart';
import '../storage_service.dart';
import '../main.dart'; // 👈 ensure MyApp is imported from your app entry file

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  String? _token;
  bool _isWebViewLoading = true;
  bool _isTokenLoaded = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final token = await StorageService.getToken();
    if (!mounted) return;

    if (token != null) {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              setState(() => _isWebViewLoading = true);
            },
            onPageFinished: (url) {
              setState(() => _isWebViewLoading = false);
            },
            onNavigationRequest: (NavigationRequest request) async {
              // 👇 Change this to the redirect URL you want to intercept
              const targetUrl = "https://app.zingmyorder.com/unauthorize/";

              if (request.url.startsWith(targetUrl)) {
                debugPrint("🎯 Intercepted redirect URL: ${request.url}");

                // Perform your logout and navigation logic
                await StorageService.clearAuth();

                if (!mounted) return NavigationDecision.prevent;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MyApp(initialIndex: 3)),
                      (route) => false,
                );

                // Prevent WebView from continuing to the intercepted URL
                return NavigationDecision.prevent;
              }

              // Allow all other navigations
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse("${Constants.cartPageUrl}${Constants.restaurantId}?token=$token"));

      setState(() {
        _token = token;
        _controller = controller;
        _isTokenLoaded = true;
      });
    } else {
      setState(() {
        _token = null;
        _isTokenLoaded = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_token != null) {
      _controller.loadRequest(Uri.parse("${Constants.cartPageUrl}${Constants.restaurantId}?token=$_token"));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for AutomaticKeepAliveClientMixin

    if (!_isTokenLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_token == null) {
      return const Center(child: Text("User not logged in."));
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isWebViewLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => false;
}
