// ignore_for_file: avoid_print

import 'dart:async';

import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/local/local_storage_services.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/constants/app_assets.dart';
import '../../../../config/typography/app_typography.dart';

class RegisterFaceScreen extends StatefulWidget {
  const RegisterFaceScreen({super.key, required this.routeName});
  final String? routeName;

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  
  // UI State
  String _uiTitle = 'Face Scanning';
  String _uiStatus = 'Initializing...';
  int _scanPercentage = 0;
  final bool _isScanComplete = false;
  bool _hasError = false;

  // Logic State
  bool _isAlreadyRegistered = false; // Change from final to mutable
  Timer? _scanTimer;
  bool _showSettingsButton = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatusAndStart();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  /// Check if user is already registered in local storage
  Future<void> _checkRegistrationStatus() async {
    try {
      final isRegistered = LocalStorageServices.getData<bool>(LocalStorageKeys.isFace.name) ?? false;
      
      setState(() {
        _isAlreadyRegistered = isRegistered;
        _uiTitle = isRegistered ? 'Verifying Face' : 'Registering Face';
        _uiStatus = isRegistered ? 'Verifying your identity...' : 'Setting up face authentication...';
      });
    } catch (e) {
      // If there's an error reading from storage, assume not registered
      print('Error checking registration status: $e');
      setState(() => _isAlreadyRegistered = false);
    }
  }

  /// Master function to handle the flow
  Future<void> _checkRegistrationStatusAndStart() async {
    // 1. Check if user is already registered in local storage
    await _checkRegistrationStatus();

    // 2. Hardware Check (Double Check Strategy)
    final canCheck = await _checkDeviceCapabilities();
    if (!canCheck) return;

    // 3. Start Visual Scanning Animation
    _animateScanningProcess(
      onComplete: () async {
        // 4. Trigger Actual Biometric Auth after visual scan hits 100%
        await _triggerBiometricAuth();
      },
    );
  }

  /// Step 2: Ensure device supports Face ID
  Future<bool> _checkDeviceCapabilities() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _handleError('Biometrics not supported on this device.');
        return false;
      }

      return true;
    } catch (e) {
      _handleError('Device check failed: $e');
      return false;
    }
  }

  /// Step 3: Simulate the "Scanning" percentage for UX
  void _animateScanningProcess({required VoidCallback onComplete}) {
    const oneSec = Duration(milliseconds: 30);
    _scanTimer = Timer.periodic(oneSec, (Timer timer) {
      if (_scanPercentage >= 100) {
        timer.cancel();
        onComplete();
      } else {
        setState(() {
          _scanPercentage += 2; // Speed of scanning
          if (_scanPercentage > 80) {
            _uiStatus = _isAlreadyRegistered ? 'Finalizing verification...' : 'Completing registration...';
          }
        });
      }
    });
  }

  /// Step 4: The actual Local Auth Trigger
  Future<void> _triggerBiometricAuth() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: _isAlreadyRegistered ? 'Verify your face to proceed' : 'Register your face for secure login',
        biometricOnly: true
      );

      if (didAuthenticate) {
        // SUCCESS: Store registration status if this was a registration
        if (!_isAlreadyRegistered) {
          await _storeRegistrationStatus();
        }

        setState(() => _uiStatus = _isAlreadyRegistered ? 'Verified Successfully!' : 'Face Registered Successfully!');
        
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            if (widget.routeName != null) {
              context.goNamed(widget.routeName!);
            } else {
              context.read<HomeBloc>().add(FetchUserDetails());
              context.pop();
            }
          }
        });
      } else {
        _handleError('Authentication cancelled. Please try again.');
      }
    } on PlatformException catch (e) {
      _handlePlatformError(e);
    } on LocalAuthException catch (e) {
      _handleLocalAuthError(e);
    } catch (e) {
      _handleError(e.toString());
    }
  }

  /// Store registration status in local storage
  Future<void> _storeRegistrationStatus() async {
    try {
      await LocalStorageServices.saveData<bool>(LocalStorageKeys.isFace.name, true);
      setState(() => _isAlreadyRegistered = true);
    } catch (e) {
      print('Error storing registration status: $e');
      // Don't show error to user, just log it
    }
  }

  void _handleLocalAuthError(LocalAuthException e) {
    String message;
    bool showSettingsButton = false;

    switch (e.code) {
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        message =
            "No face registered on this device.\n\nPlease set up Face ID/Touch ID in your phone settings to continue.";
        showSettingsButton = true;
        break;
      case LocalAuthExceptionCode.biometricLockout:
        message = "Face ID is permanently locked.\n\nPlease use your device passcode to unlock Face ID in settings.";
        showSettingsButton = true;
        break;
      case LocalAuthExceptionCode.noBiometricHardware:
        message = "Face ID/Touch ID is not available.\n\nThis device may not support biometric authentication.";
        break;
      case LocalAuthExceptionCode.noCredentialsSet:
        message = "No credentials set for biometric authentication.";
        break;
      case LocalAuthExceptionCode.unknownError:
        message = "An unknown error occurred during authentication.";
        break;
      default:
        message = "Authentication failed. Please try again.";
    }

    _handleError(message, showSettings: showSettingsButton);
  }

  void _handlePlatformError(PlatformException e) {
    String message;
    bool showSettingsButton = false;

    switch (e.code) {
      case 'NotAvailable':
        message = "Face ID/Biometrics are not available on this device.";
        break;
      case 'NotEnrolled':
        message = "No face registered on this device. Please set up Face ID in your phone settings.";
        showSettingsButton = true;
        break;
      case 'LockedOut':
        message = "Too many attempts. Face ID is temporarily locked.";
        break;
      case 'PermanentlyLockedOut':
        message = "Face ID is locked. Please use your passcode to re-enable it.";
        break;
      default:
        message = "Something went wrong. Please try again later.";
    }
  
    _handleError(message, showSettings: showSettingsButton);
  }

  void _handleError(String message, {bool showSettings = false}) {
    _scanTimer?.cancel();
    setState(() {
      _hasError = true;
      _uiStatus = message;
      _scanPercentage = 0;
      _showSettingsButton = showSettings;
    });
  }

  Widget _buildErrorState() => Column(
    children: [
      Text(
        _uiStatus,
        textAlign: TextAlign.center,
        style: AppTypography.style16Regular.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
      ).px(40),
      32.heightBox,
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _showSettingsButton ? () async => await openAppSettings() : _retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_showSettingsButton ? "Open Settings" : "Try Again"),
          ),
          16.widthBox,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kAppInfo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => widget.routeName != null ? context.goNamed(widget.routeName!) : context.pop(),
            child: Text(widget.routeName != null ? "Proceed" : "Cancel"),
          ),
        ],
      ),
    ],
  );

  void _retry() {
    setState(() {
      _hasError = false;
      _scanPercentage = 0;
      _uiStatus = 'Restarting scan...';
    });
    _checkRegistrationStatusAndStart();
  }

  @override
  Widget build(BuildContext context) {
    // Reference Image Background Color (Yellowish)
    final Color bgColor = const Color(0xFFF6D657);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Optional: Add a skip button for first-time registration
        actions: !_isAlreadyRegistered && !_hasError
            ? [
                TextButton(
                  onPressed: () => widget.routeName != null ? context.goNamed(widget.routeName!) : context.pop(),
                  child: Text('Skip', style: AppTypography.style14Regular.copyWith(color: Colors.black54)),
                ),
              ]
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              40.heightBox,

              // 1. Header Title
              Text(
                _uiTitle,
                style: AppTypography.style24Bold.copyWith(color: Colors.black, fontSize: 28, letterSpacing: 0.5),
              ),

              const Spacer(),

              // 2. Central Scanning Graphic
              _buildScanningGraphic(),

              const Spacer(),

              // 3. Status & Percentage
              if (_hasError) _buildErrorState() else _buildProgressState(),

              40.heightBox,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningGraphic() => Stack(
      alignment: Alignment.center,
      children: [
        // The Lady/User Image
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage(AppAssets.faceUserPlaceholder), fit: BoxFit.cover),
          ),
        ),
        
        // The White Overlay / Grid / Scan Lines
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: _scanPercentage < 100 && !_isScanComplete
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : null,
        ),
      ],
    );
  

  Widget _buildProgressState() => Column(
      children: [
        Text(
          "$_scanPercentage%", style: AppTypography.style24Bold.copyWith(fontSize: 48, color: Colors.black)),
        8.heightBox,
        Text(
          _uiStatus,
          style: AppTypography.style16Regular.copyWith(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        // Optional: Show hint text based on registration status
        if (_scanPercentage < 20) ...[
          16.heightBox,
          Text(
            _isAlreadyRegistered
                ? 'Please look at the camera for verification'
                : 'Please position your face within the circle',
            style: AppTypography.style14Regular.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ).px(40),
        ],
      ],
    );
  
}
