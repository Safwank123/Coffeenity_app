import 'dart:async';

import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/typography/app_typography.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {

    Timer(const Duration(milliseconds: 2500), () async {
      context.goNamed(RouteNames.home.name);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
          mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Lottie.asset(AppAssets.successAnimation),
            Text(
          "Your Order has been accepted",
          style: AppTypography.style32Bold.copyWith(fontSize: 28, height: 0),
              textAlign: TextAlign.center,
        ),
        20.heightBox,
        Text(
          "Your items has been placed and is on it’s way to being processed",
          textAlign: TextAlign.center,
          style: AppTypography.style16Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: .5)),
        ),
      ],
    ).wrapCenter().pAll(16),
  );
}
