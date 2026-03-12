import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/routes/app_routes.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/utils/app_prompts.dart';

class WebPaymentScreen extends StatefulWidget {
  const WebPaymentScreen({super.key, required this.url});

  final String url;

  @override
  State<WebPaymentScreen> createState() => _WebPaymentScreenState();
}

class _WebPaymentScreenState extends State<WebPaymentScreen> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String finish) async {
            setState(() => isLoading = false);
            if (finish.contains("vercel")) {
              context.goNamed(RouteNames.success.name);
            } 
          },
          onWebResourceError: (WebResourceError error) => AppPrompts.showError(message: error.description),
          onNavigationRequest: (NavigationRequest request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.kAppWhite,
    body: isLoading
        ? const CircularProgressIndicator().wrapCenter()
        : SafeArea(child: WebViewWidget(controller: controller)),
  );
}
