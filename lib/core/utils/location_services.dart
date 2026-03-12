// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:coffeenity/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/colors/app_colors.dart';
import 'app_log.dart';

class LocationService {
  Position? _position;
  LocationPermission? _permissionStatus;
  bool _isFetching = false;
  BuildContext get _context => navigatorKey.currentContext!;

  Future<Position?> fetchLocation({
    bool forceRefresh = false,
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Return cached position if available and not forcing refresh
    if (!forceRefresh && _position != null) {
      return _position;
    }

    // Prevent multiple simultaneous requests
    if (_isFetching) {
      AppLog.debugLog('Location fetch already in progress', 'LocationService');
      return _position;
    }

    try {
      _isFetching = true;

      // 1. Check and request permissions
      final permissionResult = await _handlePermissions();
      if (!permissionResult) {
        return null;
      }

      // 2. Fetch location with timeout
      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: desiredAccuracy, distanceFilter: 10, timeLimit: timeout),
      );
      // 3. Validate location
      if (!_isValidLocation(position)) {
        _showInvalidLocationDialog(_context);
        return null;
      }

      // 4. Cache the position
      _position = position;

      //AppLog.infoLog('Location fetched successfully: ${position.latitude}, ${position.longitude}', "LocationService");
      return position;
    } on LocationServiceDisabledException {
      _showLocationDisabledDialog();
      return null;
    } on PermissionDeniedException {
      _showPermissionDeniedDialog(_context);
      return null;
    } catch (e) {
      AppLog.errorLog('Failed to fetch location', e);
      //_showGenericErrorDialog(_context);
      return null;
    } finally {
      _isFetching = false;
    }
  }

  Future<bool> _handlePermissions() async {
    // Check if permission was previously denied forever
    if (_permissionStatus == LocationPermission.deniedForever) {
      await _showPermissionPermanentlyDeniedDialog(_context);
      return false;
    }

    // Check current permission status
    _permissionStatus = await Geolocator.checkPermission();

    if (_permissionStatus == LocationPermission.denied) {
      _permissionStatus = await Geolocator.requestPermission();

      if (_permissionStatus != LocationPermission.whileInUse && _permissionStatus != LocationPermission.always) {
        await _showPermissionDeniedDialog(_context);
        return false;
      }
    }

    return true;
  }

  bool _isValidLocation(Position position) {
    const minLat = -90.0;
    const maxLat = 90.0;
    const minLon = -180.0;
    const maxLon = 180.0;

    return position.latitude >= minLat &&
        position.latitude <= maxLat &&
        position.longitude >= minLon &&
        position.longitude <= maxLon;
  }

  // Dialog methods
  Future<void> _showLocationDisabledDialog() async {
    await showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled on your device. '
          'Please enable them in Settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.kAppWhite)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: AppColors.kAppWhite)),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'This app needs location permission to provide location-based features. '
          'Please grant permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.kAppWhite)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Grant Permission', style: TextStyle(color: AppColors.kAppWhite)),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. '
          'Please enable it in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.kAppWhite)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: AppColors.kAppWhite)),
          ),
        ],
      ),
    );
  }



  Future<void> _showInvalidLocationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Location'),
        content: const Text(
          'The obtained location appears to be invalid. '
          'Please try again or check your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.kAppWhite)),
          ),
        ],
      ),
    );
  }

  // Future<void> _showGenericErrorDialog(BuildContext context) async {
  //   await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Location Error'),
  //       content: const Text(
  //         'An error occurred while fetching your location. '
  //         'Please try again later.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK', style: TextStyle(color: AppColors.kAppWhite)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Clear cached location
  void clearCache() {
    _position = null;
  }

  // Get last known location as fallback
  Future<Position?> getLastKnownLocation(BuildContext context) async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null && _isValidLocation(position)) {
        return position;
      }
      return null;
    } catch (e) {
      AppLog.errorLog('Failed to get last known location', e);
      return null;
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location with optional fallback to last known location
  Future<Position?> requestLocationWithFallback({bool showDialogs = true, bool useLastKnownAsFallback = true}) async {
    final position = await fetchLocation();

    if (position == null && useLastKnownAsFallback) {
      final lastKnown = await getLastKnownLocation(_context);
      if (lastKnown != null && showDialogs) {
        _showLastKnownLocationDialog(_context);
      }
      return lastKnown;
    }

    return position;
  }

  Future<void> _showLastKnownLocationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Using Last Known Location'),
        content: const Text('Unable to get current location. Using your last known location instead.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.kAppWhite)),
          ),
        ],
      ),
    );
  }
}

// Optional: You can keep the exception classes for logging or internal use
class LocationException implements Exception {
  final String message;
  final LocationErrorType errorType;

  LocationException(this.message, this.errorType);

  @override
  String toString() => 'LocationException: $message ($errorType)';
}

enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  timeout,
  invalidLocation,
  networkError,
}
