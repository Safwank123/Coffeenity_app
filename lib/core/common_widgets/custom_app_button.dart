import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';

import '../../config/typography/app_typography.dart';

class CustomAppButton extends StatefulWidget {
  const CustomAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.buttonType = ButtonType.filled,
    this.isLoading = false,
    this.textFontSize,
    this.textFontWeight,
    this.verticalPadding,
    this.icon,
    this.iconPosition,
    this.textStyle,
  });
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonType buttonType;
  final bool isLoading;
  final double? textFontSize;
  final FontWeight? textFontWeight;
  final double? verticalPadding;
  final Widget? icon;
  final TextStyle? textStyle;
  final IconPosition? iconPosition;
  final double? borderRadius;

  @override
  State<CustomAppButton> createState() => _CustomAppButtonState();
}

class _CustomAppButtonState extends State<CustomAppButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFilled = widget.buttonType == ButtonType.filled;
    final buttonColor = widget.isLoading ? theme.disabledColor : widget.backgroundColor ?? theme.colorScheme.primary;
    final textColor = widget.textColor ?? theme.colorScheme.onPrimary;

    // Determine colors based on button type and provided values
    final Color effectiveBackgroundColor = isFilled ? buttonColor : Colors.transparent;

    final Color effectiveTextColor = textColor;

    // Border for outlined button
    final BorderSide borderSide = isFilled ? BorderSide.none : BorderSide(color: buttonColor, width: 1.5);

    return GestureDetector(
      onTapDown: (details) {
        if (!widget.isLoading) {
          setState(() => _scale = 0.99);
        }
      },
      onTapUp: (details) {
        if (!widget.isLoading) {
          setState(() => _scale = 1.0);
          widget.onPressed?.call();
        }
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: Transform.scale(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 25),
            border: Border.fromBorderSide(borderSide),
          ),
          child: Container(
            width: context.width,
            padding: EdgeInsets.symmetric(vertical: widget.verticalPadding ?? 14, horizontal: 24),
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFilled ? effectiveTextColor : effectiveBackgroundColor,
                      ),
                    ),
                  ).wrapCenter()
                : Directionality(
                    textDirection: widget.iconPosition == IconPosition.end ? TextDirection.rtl : TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.icon != null) widget.icon!,
                        5.widthBox,
                        Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style:
                              widget.textStyle ??
                              AppTypography.style16SemiBold.copyWith(
                                color: effectiveTextColor,
                                fontSize: widget.textFontSize,
                                fontWeight: widget.textFontWeight,
                              ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

enum ButtonType { filled, outlined }

enum IconPosition { start, end }
