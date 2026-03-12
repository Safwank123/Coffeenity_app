import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/common_widgets/custom_text_field.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/routes/app_routes.dart';

class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.zipController,
    required this.passwordController,
    required this.focusNodes,
    this.isEdit = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController zipController;
  final TextEditingController passwordController;
  final List<FocusNode> focusNodes;
  final bool isEdit;

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> with TickerProviderStateMixin {
  late final List<AnimationController> _animationControllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;
  
  // Track the current total fields based on isEdit
  late int _totalFields;

  @override
  void initState() {
    super.initState();
    _totalFields = widget.isEdit ? 6 : 7; // 6 fields for edit mode (without password), 7 for create mode
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(UserInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize animations if isEdit changes
    if (oldWidget.isEdit != widget.isEdit) {
      final newTotalFields = widget.isEdit ? 6 : 7;
      if (newTotalFields != _totalFields) {
        for (final controller in _animationControllers) {
          controller.dispose();
        }
        _totalFields = newTotalFields;
        _initializeAnimations();
      }
    }
  }

  void _initializeAnimations() {
    const int baseDuration = 500;
    const int staggerDelay = 100;

    _animationControllers = List.generate(
      _totalFields,
      (index) => AnimationController(
        duration: Duration(milliseconds: baseDuration + (index * staggerDelay)),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers
        .map(
          (controller) =>
              Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _slideAnimations = _animationControllers
        .map(
          (controller) => Tween<Offset>(
            begin: const Offset(0.0, 0.9),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    // Start animations
    for (final controller in _animationControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: widget.formKey,
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Animated Title
        _buildAnimatedTitle(),
        20.heightBox,

        // Animated Form Fields
        _buildAnimatedFormFields(),
        80.heightBox,
      ],
    ),
  );

  Widget _buildAnimatedTitle() => FadeTransition(
    opacity: _fadeAnimations[0],
    child: SlideTransition(
      position: _slideAnimations[0],
      child: Text(
        widget.isEdit ? "Update your information" : "Tell us about yourself",
        style: AppTypography.style24Bold,
      ),
    ),
  );

  Widget _buildAnimatedFormFields() => Column(
    children: [
      _buildAnimatedTextField(
        1,
        widget.firstNameController,
        "First Name",
        (value) => _validateName(value, 'First Name'),
        focusNode: widget.focusNodes[0],
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(
              r"[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð'\-\s]",
            ),
          ),
          LengthLimitingTextInputFormatter(30),
        ],
        textInputAction: TextInputAction.next,
      ),

      _buildAnimatedTextField(
        2,
        widget.lastNameController,
        "Last Name",
        (value) => _validateName(value, 'Last Name'),
        focusNode: widget.focusNodes[1],
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(
              r"[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð'\-\s]",
            ),
          ),
          LengthLimitingTextInputFormatter(30),
        ],
        textInputAction: TextInputAction.next,
      ),

      _buildAnimatedTextField(
        3,
        widget.emailController,
        "Email",
        _validateEmail,
        focusNode: widget.focusNodes[2],
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [LengthLimitingTextInputFormatter(100)],
        textInputAction: TextInputAction.next,
      ),

      _buildAnimatedTextField(
        4,
        widget.phoneNumberController,
        "Phone Number",
        _validatePhoneNumber,
        focusNode: widget.focusNodes[3],
        isPhone: true,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        textInputAction: TextInputAction.next,
      ),

      _buildAnimatedTextField(
        5,
        widget.zipController,
        "Zip Code",
        _validateZipCode,
        focusNode: widget.focusNodes[4],
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
          _ZipCodeInputFormatter(),
        ],
        textInputAction: widget.isEdit ? TextInputAction.done : TextInputAction.next,
      ),

      // Password field - conditionally shown and animated
      if (!widget.isEdit)
        _buildAnimatedTextField(
          _totalFields - 1, // Last animation index for password field
          widget.passwordController,
          "Password",
          _validatePassword,
          focusNode: widget.focusNodes[5],
          textInputAction: TextInputAction.done,
          isPassword: true,
        ),
      if (!widget.isEdit)
      Text.rich(
        TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: AppColors.kAppWhite),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: AppColors.kAppWhite,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.kAppWhite,
                decorationThickness: 2,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => context.goNamed(RouteNames.login.name),
            ),
          ],
        ),
      ).wrapCenter(),
    ],
  );

  Widget _buildAnimatedTextField(
    int animationIndex,
    TextEditingController controller,
    String hintText,
    String? Function(String?)? validator, {
    TextInputType? keyboardType,
    FocusNode? focusNode,
    bool isPhone = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    bool readOnly = false,
    bool isPassword = false,
    bool showCursor = true,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) => FadeTransition(
    opacity: _fadeAnimations[animationIndex],
    child: SlideTransition(
      position: _slideAnimations[animationIndex],
      child: CustomTextField(
        focusNode: focusNode,
        controller: controller,
        hintText: hintText,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        readOnly: readOnly,
        isPassword: isPassword,
        showCursor: showCursor,
        onTap: onTap,
        suffixIcon: suffixIcon,
        prefixIcon: isPhone
            ? Text("+1", style: AppTypography.style16SemiBold.copyWith(color: AppColors.kAppBlack)).pAll(16)
            : null,
      ).pOnly(bottom: 30),
    ),
  );

  // Validator methods remain the same...
  String? _validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if (trimmedValue.length > 30) {
      return '$fieldName cannot exceed 30 characters';
    }

    if (!RegExp(
      r"^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð'\-\.\s]+$",
    ).hasMatch(trimmedValue)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    if (RegExp(r"['\-\.]{2,}").hasMatch(trimmedValue)) {
      return '$fieldName cannot have consecutive special characters';
    }

    if (RegExp(r"^['\-\.]|['\-\.]$").hasMatch(trimmedValue)) {
      return '$fieldName cannot start or end with a special character';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length > 100) {
      return 'Email cannot exceed 100 characters';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', caseSensitive: false);

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address (e.g., user@example.com)';
    }

    final commonProviders = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com'];
    final domain = trimmedValue.split('@').last.toLowerCase();
    if (commonProviders.contains(domain)) {
      return null;
    }

    final eduRegex = RegExp(r'\.edu$', caseSensitive: false);
    if (eduRegex.hasMatch(domain)) {
      return null;
    }

    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zip code is required';
    }

    final trimmedValue = value.trim();

    final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    if (!zipRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid US zip code (e.g., 12345 or 12345-6789)';
    }

    final zipDigits = trimmedValue.replaceAll('-', '');
    if (zipDigits.length >= 5) {
      final firstThree = int.tryParse(zipDigits.substring(0, 3));
      if (firstThree != null) {
        if (firstThree < 1 || firstThree > 999) {
          return 'Please enter a valid US zip code';
        }
      }
    }

    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final trimmedValue = value.trim();

    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid US phone number (e.g., 1234567890)';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }
}

class _ZipCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (newText.length > 5) {
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }

    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
