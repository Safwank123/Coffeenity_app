import 'package:coffeenity/core/common_widgets/custom_app_button.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/core/utils/app_prompts.dart';
import 'package:coffeenity/core/utils/location_services.dart';
import 'package:coffeenity/features/auth/data/models/register_request.dart';
import 'package:coffeenity/features/auth/data/models/user_preference_request.dart';
import 'package:coffeenity/features/auth/presentation/widgets/user_interest_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../../../home/data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/summary_widget.dart';
import '../widgets/terms_widget.dart';
import '../widgets/user_info_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.profile});
  final UserModel? profile;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final PageController _pageController;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _zipController;
  late final TextEditingController _passwordController;
  int _selectedPage = 0;
  int _selectedOption = 0;
  late bool _shareLocation;
  Position? _userLocation;
  late final List<String> _selectedCoffees;
  late final List<String> _selectedCoffeeShops;
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _formKey = GlobalKey<FormState>();
    _firstNameController = TextEditingController(text: widget.profile?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.profile?.lastName ?? '');
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _phoneNumberController = TextEditingController(text: widget.profile?.phone ?? '');
    _zipController = TextEditingController(text: widget.profile?.zipcode ?? '');
    _passwordController = TextEditingController();

    // Initialize selected coffees and coffee shops
    _selectedCoffees = widget.profile?.primaryPreferences?.favouriteCoffee.toList() ?? [];
    _selectedCoffeeShops = [];

    _shareLocation = widget.profile?.primaryPreferences?.isLocationEnabled ?? false;

    for (int i = 0; i < 6; i++) {
      _focusNodes.add(FocusNode());
    }

    // Add listeners to focus nodes
    for (final focusNode in _focusNodes) {
      focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() => setState(() => _isKeyboardVisible = _focusNodes.any((node) => node.hasFocus));

  @override
  void dispose() {
    for (final focusNode in _focusNodes) {
      focusNode.removeListener(_onFocusChange);
      focusNode.dispose();
    }
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _zipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isKeyboardVisible = false;

  void _onPageChanged(int value) {
    _dismissKeyboard();
    setState(() => _selectedPage = value);
  }

  // Method to dismiss keyboard
  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  // Method to validate all required fields
  bool _validateAllFields() {
    // For registration, password is required
    if (widget.profile == null && _passwordController.text.trim().isEmpty) {
      AppPrompts.showError(message: "Password is required");
      return false;
    }

    // Validate email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (_emailController.text.trim().isEmpty || !emailRegex.hasMatch(_emailController.text.trim())) {
      AppPrompts.showError(message: "Please enter a valid email");
      return false;
    }

    // Validate other required fields
    if (_firstNameController.text.trim().isEmpty) {
      AppPrompts.showError(message: "First name is required");
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      AppPrompts.showError(message: "Last name is required");
      return false;
    }

    if (_phoneNumberController.text.trim().isEmpty) {
      AppPrompts.showError(message: "Phone number is required");
      return false;
    }

    if (_zipController.text.trim().isEmpty) {
      AppPrompts.showError(message: "ZIP code is required");
      return false;
    }

    if (_selectedCoffees.isEmpty) {
      AppPrompts.showError(message: "Please select at least one coffee preference");
      return false;
    }

    // if (_selectedCoffeeShops.isEmpty) {
    //   AppPrompts.showError(message: "Please select at least one coffee shop");
    //   return false;
    // }

    // // For registration only - validate terms acceptance
    // if (widget.profile == null && _selectedOption != 1) {
    //   AppPrompts.showError(message: "Please accept terms and conditions");
    //   return false;
    // }

    return true;
  }

  // Method to handle next button press with keyboard dismissal
  void _handleNextButton() {
    _dismissKeyboard(); // Always dismiss keyboard first

    if (_selectedPage == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    } else if (_selectedPage == 1) {
      if (_selectedCoffees.isEmpty) {
        AppPrompts.showError(message: "Please select at least one coffee");
        return;
      }
      // if (_selectedCoffeeShops.isEmpty) {
      //   AppPrompts.showError(message: "Please select at least one coffee shop");
      //   return;
      // }

      if (widget.profile == null) {
        // For registration, go to terms page
        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      } else {
        // For edit, go to summary page
        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    } else if (_selectedPage == 2 && widget.profile == null) {
      // // Terms page for registration
      // if (_selectedOption != 1) {
      //   AppPrompts.showError(message: "Please accept terms and conditions");
      //   return;
      // }
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else if ((_selectedPage == 2 && widget.profile != null) || (_selectedPage == 3 && widget.profile == null)) {
      // Summary page - final submission
      if (!_validateAllFields()) {
        return;
      }

      context.read<AuthBloc>().add(
        Register(
          isEdit: widget.profile != null,
          registerRequest: RegisterRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneNumberController.text.trim(),
            zipcode: _zipController.text.trim(),
          ),
          userPreferenceRequest: UserPreferenceRequest(
            favouriteCoffee: _selectedCoffees,
            notificationType: "Daily",
            frequency: '3x',
            isLocationEnabled: _shareLocation,
            latitude: _userLocation?.latitude,
            longitude: _userLocation?.longitude,
          ),
        ),
      );
    }
  }

  // Method to handle page navigation with keyboard dismissal
  void _navigateToPage(int page) {
    _dismissKeyboard();
    setState(() => _selectedPage = page);
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Widget _buildAnimatedProgressIndicator(int index) => AnimatedContainer(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    height: 5,
    decoration: BoxDecoration(
      color: _selectedPage >= index ? AppColors.kAppSecondary : AppColors.kAppDisabled,
      borderRadius: BorderRadius.circular(25),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 2),
  ).expanded();

  String _getButtonText() {
    if (_selectedPage == (widget.profile != null ? 2 : 3)) {
      return widget.profile != null ? "Update Profile" : "Complete On-boarding";
    }
    return "Next";
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _dismissKeyboard,
    behavior: HitTestBehavior.opaque,
    child: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.emitState == AuthEmitState.registered) {
          context.goNamed(RouteNames.loading.name);
        } else if (state.emitState == AuthEmitState.updated) {
          Navigator.pop(context);
          AppPrompts.showSuccess(message: "Profile updated successfully");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: "logo",
            child: CustomImageWidget(imageUrl: AppAssets.appBar, width: 200),
          ),
          leading: widget.profile != null
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
              : null,
        ),
        floatingActionButton: _isKeyboardVisible
            ? null
            : BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                  child: CustomAppButton(
                    isLoading: state.emitState == AuthEmitState.loading,
                    key: ValueKey(_selectedPage),
                    text: _getButtonText(),
                    onPressed: _handleNextButton,
                  ).h(50)
                ).px(16),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Stack(
          children: [
            if (_selectedPage == 0 || _selectedPage == 1)
              CustomImageWidget(
                imageUrl: _selectedPage == 0 ? AppAssets.onboarding1 : AppAssets.onboarding2,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            if (_selectedPage == 0 || _selectedPage == 1) Container(color: AppColors.kAppBlack.withValues(alpha: 0.5)),
            Column(
              children: [
                Row(
                  children: List.generate(
                    widget.profile == null ? 4 : 3,
                    (index) => _buildAnimatedProgressIndicator(index),
                  ),
                ).pAll(16),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: _onPageChanged,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      UserInfoWidget(
                        formKey: _formKey,
                        focusNodes: _focusNodes,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        phoneNumberController: _phoneNumberController,
                        zipController: _zipController,
                        passwordController: _passwordController,
                        isEdit: widget.profile != null,
                      ),
                      UserInterestWidget(
                        selectedCoffeeShops: _selectedCoffeeShops,
                        onCoffeeShopSelect: (coffeeShop) => setState(() {
                          if (coffeeShop == "Select all") {
                            _selectedCoffeeShops.clear();
                            _selectedCoffeeShops.addAll(Coffee.coffeeShopList.map((coffeeShop) => coffeeShop.name));
                          } else {
                            if (_selectedCoffeeShops.contains(coffeeShop)) {
                              _selectedCoffeeShops.remove(coffeeShop);
                            } else {
                              _selectedCoffeeShops.add(coffeeShop);
                            }
                          }
                        }),
                        selectedCoffees: _selectedCoffees,
                        onSelect: (coffee) => setState(() {
                          if (coffee == "Select all") {
                            _selectedCoffees.clear();
                            _selectedCoffees.addAll(Coffee.coffeeList.map((coffee) => coffee.name));
                          } else {
                            if (_selectedCoffees.contains(coffee)) {
                              _selectedCoffees.remove(coffee);
                            } else {
                              _selectedCoffees.add(coffee);
                            }
                          }
                        }),
                      ),
                      if (widget.profile == null)
                        TermsWidget(
                          selectedOption: _selectedOption,
                          onChanged: (value) => setState(() => _selectedOption = (value ?? 0)),
                        ),
                      SummaryWidget(
                        shareLocation: _shareLocation,
                        selectedCoffeeShops: _selectedCoffeeShops,
                        onChanged: (value) async {
                          if (value) {
                            final location = await LocationService().fetchLocation();
                            if (location != null) {
                              setState(() {
                                _shareLocation = value;
                                _userLocation = location;
                              });
                            } else {
                              AppPrompts.showError(message: "Could not fetch location");
                            }
                          } else {
                            setState(() => _shareLocation = value);
                          }
                        },
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        email: _emailController.text.trim(),
                        phoneNumber: _phoneNumberController.text.trim(),
                        zipCode: _zipController.text.trim(),
                        coffees: _selectedCoffees,
                        onUserInfoTap: () => _navigateToPage(0),
                        onCoffeeFlavorsTap: () => _navigateToPage(1),
                        onCoffeeShopsTap: () => _navigateToPage(1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
