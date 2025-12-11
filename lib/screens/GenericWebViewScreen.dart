import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GenericWebViewScreen extends StatefulWidget {
  final String url;

  const GenericWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<GenericWebViewScreen> createState() => _DeleteAccountWebViewScreenState();
}

class _DeleteAccountWebViewScreenState extends State<GenericWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Delete Account')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
