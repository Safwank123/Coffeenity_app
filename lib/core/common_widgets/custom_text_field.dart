import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_mobile_field/country_picker_dialog.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

import '../../config/typography/app_typography.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.disableAllBorder = false,
    this.isPassword = false,
    this.readOnly = false,
    this.filled = true,
    this.inputFormatters,
    this.enabled = true,
    this.controller,
    this.keyboardType,
    this.validator,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.initialValue,
    this.errorText,
    this.helperText,
    this.helperMaxLines,
    this.helperStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.hintStyle,
    this.labelText,
    this.labelStyle,
    this.floatingLabelBehavior,
    this.floatingLabelStyle,
    this.errorStyle,
    this.errorMaxLines,
    this.contentPadding,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.counterText,
    this.counterStyle,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.autovalidateMode,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.expands = false,
    this.showCursor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.headingLabelText,
    this.headingStyle,
    this.isRequired = false,
    this.disabledBorder,
    this.isPhone = false,
  });

  final String? hintText;
  final bool disableAllBorder;
  final bool isPassword;
  final bool readOnly;
  final bool filled;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final String? initialValue;
  final String? errorText;
  final String? helperText;
  final int? helperMaxLines;
  final TextStyle? helperStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextStyle? floatingLabelStyle;
  final TextStyle? errorStyle;
  final int? errorMaxLines;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final String? counterText;
  final TextStyle? counterStyle;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final String obscuringCharacter;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final bool expands;
  final bool? showCursor;
  final Color? cursorColor;
  final double? cursorHeight;
  final double cursorWidth;
  final Radius? cursorRadius;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? disabledBorder;
  final String? headingLabelText;
  final TextStyle? headingStyle;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool isPhone;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) => widget.isPhone
      ? IntlMobileField(
          initialCountryCode: "US",
          showDropdownIcon: false,
          showFieldCountryFlag: false,
          dropdownIconPosition: Position.trailing,
          autovalidateMode: AutovalidateMode.disabled,
          pickerDialogStyle: PickerDialogStyle(
            searchFieldTextStyle: AppTypography.style16Regular.copyWith(color: AppColors.kAppTextPrimary),
          ),
          dropdownTextStyle: AppTypography.style16SemiBold.copyWith(color: AppColors.kAppTextPrimary),
          flagsButtonPadding: const EdgeInsets.only(left: 8),
          dropdownIcon: const Icon(Icons.keyboard_arrow_down),
          fillColor: widget.fillColor ?? AppColors.kAppOnSurface,
          controller: widget.controller,
          maxLines: widget.maxLines,
          initialValue: widget.initialValue,
          obscureText: widget.isPassword && !isPasswordVisible,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          onChanged: (value) => widget.onChanged?.call(value.completeNumber),
          onTap: widget.onTap,
          onSaved: (value) => widget.onSaved?.call(value?.completeNumber),
          textInputAction: widget.textInputAction,
          style: widget.style ?? AppTypography.style16Regular.copyWith(color: AppColors.kAppBlack),
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          expands: widget.expands,
          showCursor: widget.showCursor,
          cursorColor: widget.cursorColor,
          cursorHeight: widget.cursorHeight,
          cursorWidth: widget.cursorWidth,
          cursorRadius: widget.cursorRadius,
          scrollPadding: widget.scrollPadding,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperMaxLines: widget.helperMaxLines,
            helperStyle: widget.helperStyle,
            border:
                widget.border ??
                (widget.disableAllBorder
                    ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
                    : null),
            enabledBorder:
                widget.enabledBorder ??
                (widget.disableAllBorder
                    ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
                    : null),
            focusedBorder:
                widget.focusedBorder ??
                (widget.disableAllBorder
                    ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
                    : null),
            errorBorder:
                widget.errorBorder ??
                (widget.disableAllBorder
                    ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
                    : null),
            focusedErrorBorder:
                widget.focusedErrorBorder ??
                (widget.disableAllBorder
                    ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
                    : null),
            disabledBorder:
                widget.disabledBorder ??
                (widget.disableAllBorder
                    ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
                    : null),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                  )
                : widget.suffixIcon,
            hintStyle: widget.hintStyle,
            labelText: widget.labelText,
            labelStyle: widget.labelStyle,
            floatingLabelBehavior: widget.floatingLabelBehavior,
            floatingLabelStyle: widget.floatingLabelStyle,
            errorStyle: widget.errorStyle,
            errorMaxLines: widget.errorMaxLines,
            contentPadding: widget.hintText?.toLowerCase().contains("search") == true
                ? const EdgeInsets.symmetric(horizontal: 10)
                : widget.contentPadding,
            prefixIconConstraints: widget.prefixIconConstraints,
            suffixIconConstraints: widget.suffixIconConstraints,
            counterText: "",
            counterStyle: widget.counterStyle,
            enabled: widget.enabled,
          ),
          validator: (value) => widget.validator?.call(value?.completeNumber),
        )
      : TextFormField(
    controller: widget.controller,
    keyboardType: widget.keyboardType,
    validator: widget.validator,
    maxLength: widget.maxLength,
    minLines: widget.minLines,
    maxLines: widget.maxLines,
    initialValue: widget.initialValue,
    obscureText: widget.isPassword && !isPasswordVisible,
    readOnly: widget.readOnly,
    enabled: widget.enabled,
    focusNode: widget.focusNode,
    onChanged: widget.onChanged,
    onTap: widget.onTap,
    onEditingComplete: widget.onEditingComplete,
    onFieldSubmitted: widget.onFieldSubmitted,
    onSaved: widget.onSaved,
    autovalidateMode: widget.autovalidateMode,
    textInputAction: widget.textInputAction,
    textCapitalization: widget.textCapitalization,
          style: widget.style ?? AppTypography.style16Regular.copyWith(color: AppColors.kAppBlack),
    strutStyle: widget.strutStyle,
    textAlign: widget.textAlign,
    textAlignVertical: widget.textAlignVertical,
    autofocus: widget.autofocus,
    obscuringCharacter: widget.obscuringCharacter,
    autocorrect: widget.autocorrect,
    smartDashesType: widget.smartDashesType,
    smartQuotesType: widget.smartQuotesType,
    enableSuggestions: widget.enableSuggestions,
    expands: widget.expands,
    showCursor: widget.showCursor,
    cursorColor: widget.cursorColor,
    cursorHeight: widget.cursorHeight,
    cursorWidth: widget.cursorWidth,
    cursorRadius: widget.cursorRadius,
    scrollPadding: widget.scrollPadding,
    enableInteractiveSelection: widget.enableInteractiveSelection,
    selectionControls: widget.selectionControls,
    buildCounter: widget.buildCounter,
    scrollPhysics: widget.scrollPhysics,
    scrollController: widget.scrollController,
    inputFormatters: widget.inputFormatters,
    restorationId: widget.restorationId,
    enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
    decoration: InputDecoration(
      hintText: widget.hintText,
      errorText: widget.errorText,
      helperText: widget.helperText,
      helperMaxLines: widget.helperMaxLines,
      helperStyle: widget.helperStyle,
      border:
          widget.border ??
          (widget.disableAllBorder
              ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
              : null),
      enabledBorder:
          widget.enabledBorder ??
          (widget.disableAllBorder
              ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
              : null),
      focusedBorder:
          widget.focusedBorder ??
          (widget.disableAllBorder
              ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
              : null),
      errorBorder:
          widget.errorBorder ??
          (widget.disableAllBorder
              ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
              : null),
      focusedErrorBorder:
          widget.focusedErrorBorder ??
          (widget.disableAllBorder
              ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
              : null),
      disabledBorder:
          widget.disabledBorder ??
          (widget.disableAllBorder
              ? OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(20))
              : null),
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.isPassword
          ? IconButton(
              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
            )
          : widget.suffixIcon,
      filled: widget.filled,
      fillColor: widget.fillColor,
      hintStyle: widget.hintStyle,
      labelText: widget.labelText,
      labelStyle: widget.labelStyle,
      floatingLabelBehavior: widget.floatingLabelBehavior,
      floatingLabelStyle: widget.floatingLabelStyle,
      errorStyle: widget.errorStyle,
      errorMaxLines: widget.errorMaxLines,
      contentPadding: widget.hintText?.toLowerCase().contains("search") == true
          ? const EdgeInsets.symmetric(horizontal: 10)
          : widget.contentPadding,
      prefixIconConstraints: widget.prefixIconConstraints,
      suffixIconConstraints: widget.suffixIconConstraints,
      counterText: widget.counterText,
      counterStyle: widget.counterStyle,
      enabled: widget.enabled,
    ),
  );
}
