import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebView extends StatelessWidget {
  const StripeWebView({Key? key, required this.uri, required this.returnUri}) : super(key: key);

  final String uri;
  final Uri returnUri;

  @override
  Widget build(BuildContext context) {
    return WebView(
        initialUrl: uri,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (navigation) {
          final uri = Uri.parse(navigation.url);
          if (uri.scheme == returnUri.scheme &&
              uri.host == returnUri.host &&
              uri.queryParameters['requestId'] == returnUri.queryParameters['requestId']) {
            Navigator.pop(context, true);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        });
  }
}
