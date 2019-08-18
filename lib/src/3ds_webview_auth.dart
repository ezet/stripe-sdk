//import 'package:flutter/material.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//
//class ScaAuth extends StatelessWidget {
//  ScaAuth(this.action) : url = action['redirect_to_url']['url'];
//
//  final Map<dynamic, dynamic> action;
//  final String url;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text('Flutter WebView example'),
//        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
//        actions: <Widget>[
////          NavigationControls(_controller.future),
////          SampleMenu(_controller.future),
//        ],
//      ),
//      // We're using a Builder here so we have a context that is below the Scaffold
//      // to allow calling Scaffold.of(context) so we can show a snackbar.
//      body: WebView(
//        initialUrl: url,
//        javascriptMode: JavascriptMode.unrestricted,
////        onWebViewCreated: (WebViewController webViewController) {
////          _controller.complete(webViewController);
////        },
//        javascriptChannels: <JavascriptChannel>[
//          _toasterJavascriptChannel(context),
//        ].toSet(),
//        navigationDelegate: (NavigationRequest request) {
//          print('allowing navigation to $request');
//          return NavigationDecision.navigate;
//        },
//        onPageFinished: (String url) {
//          print('Page finished loading: $url');
//        },
//      ),
////      floatingActionButton: favoriteButton(),
//    );
//  }
//
//  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//    return JavascriptChannel(
//        name: 'Payment',
//        onMessageReceived: (JavascriptMessage message) {
//          Navigator.pop(context);
//          Scaffold.of(context).showSnackBar(
//            SnackBar(content: Text(message.message)),
//          );
//        });
//  }
//}
