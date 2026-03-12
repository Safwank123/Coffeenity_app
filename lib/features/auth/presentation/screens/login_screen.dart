import 'package:coffeenity/config/routes/app_routes.dart';
import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/common_widgets/custom_app_button.dart';
import 'package:coffeenity/core/common_widgets/custom_app_scaffold.dart';
import 'package:coffeenity/core/common_widgets/custom_text_field.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    bottomNavigationBar: BottomAppBar(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.emitState == AuthEmitState.loggedIn) {
            context.goNamed(RouteNames.home.name);
          }
        },
        builder: (context, state) => CustomAppButton(
          isLoading: state.emitState == AuthEmitState.loading,
          text: "Login",
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<AuthBloc>().add(
                Login(email: _emailController.text.trim(), password: _passwordController.text.trim()),
              );
            }
          },
        ),
      ),
    ),
    padding: EdgeInsets.all(16),
    body: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          50.heightBox,
          Hero(
            tag: "splash_logo",
            child: CustomImageWidget(imageUrl: AppAssets.splashLogo),
          ),
          10.heightBox,
          Text("Welcome Back ☕", style: AppTypography.style22SemiBold),
          Text("Login to continue", style: AppTypography.style16Regular.copyWith(color: AppColors.kAppDisabled)),
          20.heightBox,
          CustomTextField(
            controller: _emailController,
            hintText: "Enter Email",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email is required";
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          16.heightBox,

          CustomTextField(
            controller: _passwordController,
            hintText: "Enter Password",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              return null;
            },
            textInputAction: TextInputAction.done,

            isPassword: true,
          ),
          36.heightBox,
          Text.rich(
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(color: AppColors.kAppWhite),
              children: [
                TextSpan(
                  text: "Register",
                  style: TextStyle(
                    color: AppColors.kAppWhite,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.kAppWhite,
                    decorationThickness: 2,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () => context.goNamed(RouteNames.register.name),
                ),
              ],
            ),
          ).wrapCenter(),
        ],
      ),
    ),
  );
}
