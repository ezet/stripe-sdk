import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebView extends StatelessWidget {
  const StripeWebView({Key? key, required this.uri, required this.returnUri}) : super(key: key);

  final String uri;
  final Uri returnUri;

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (request) {
        final uri = Uri.parse(request.url);
        if (uri.scheme == returnUri.scheme &&
            uri.host == returnUri.host &&
            uri.queryParameters['requestId'] == returnUri.queryParameters['requestId']) {
          Navigator.pop(context, true);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      }
    ))
    ..loadRequest(Uri.parse(uri));
    return WebViewWidget(controller: controller);
  }
}
