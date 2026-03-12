import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/typography/app_typography.dart';

class InstructionsBottomSheet extends StatelessWidget {
  const InstructionsBottomSheet({super.key});
  static final List<String> _instructions = [
    "No menus, no hassle.",
    "Just speak you order and number of drinks—customize with requests in seconds.",
    "Say Order Coffee or menu item ( eg. Turkish Coffee) Regular/ Large",
    //"Optional: Save \"SAVE\" to store exact for instant reorders—eay, just say, \"SAVE coffee 007.\"",
  ];

  @override
  Widget build(BuildContext context) => BottomSheet(
    onClosing: () => {},
    showDragHandle: true,
    backgroundColor: AppColors.kAppSplashBackground,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._instructions.map((instruction) {
          final index = _instructions.indexOf(instruction);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: index == 3 ? AppColors.kAppAmber : AppColors.kAppWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(instruction, style: AppTypography.style16Regular.copyWith(color: AppColors.kAppBlack)),
              trailing: const Icon(Icons.gpp_maybe_outlined, color: AppColors.kAppBlack),
            ),
          );
        }),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.kAppRed, textStyle: AppTypography.style18Regular),
          child: const Text("Close"),
        ).wrapCenter(),
      ],
    ).px(16).wFull(context),
  );
}
