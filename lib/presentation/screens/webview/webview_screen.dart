import 'dart:developer';

import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  final String url;
  const WebviewScreen({super.key, required this.url});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // Handle mailto: and tel: links
            if (url.startsWith('mailto:') || url.startsWith('tel:')) {
              try {
                final uri = Uri.parse(url);
                // Don't check canLaunchUrl, just try to launch directly
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                log("[Success] Opened: $url");
              } catch (e) {
                log("[Error] Could not launch $url: $e");
                if (mounted) {
                  Fluttertoast.showToast(
                    msg:
                        "Could not open email app. Please install an email app.",
                    toastLength: Toast.LENGTH_LONG,
                  );
                }
              }
              return NavigationDecision.prevent;
            }

            // Allow all other navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: ""),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: SmallLoader(),
            ),
        ],
      ),
    );
  }
}
