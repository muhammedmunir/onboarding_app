import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationProvider with ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Comprehensive check for biometric availability
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if device supports biometric authentication
      final supported = await isDeviceSupported();
      if (!supported) {
        debugPrint('Biometric not supported on this device');
        return false;
      }

      // Check if biometric hardware is available
      final canCheck = await checkBiometricAvailability();
      if (!canCheck) {
        debugPrint('Biometric hardware not available');
        return false;
      }

      // Check if user has enrolled biometrics
      final available = await getAvailableBiometrics();
      if (available.isEmpty) {
        debugPrint('No biometrics enrolled');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('isBiometricAvailable error: $e');
      return false;
    }
  }

  /// Returns true if the device *can* check biometrics (hardware + OS)
  Future<bool> checkBiometricAvailability() async {
    try {
      final can = await _auth.canCheckBiometrics;
      debugPrint('checkBiometricAvailability -> $can');
      return can;
    } catch (e) {
      debugPrint('checkBiometricAvailability error: $e');
      return false;
    }
  }

  /// Returns list of available biometric types (fingerprint, face, iris...)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> available = await _auth.getAvailableBiometrics();
      debugPrint('getAvailableBiometrics -> $available');
      return available;
    } on PlatformException catch (e) {
      debugPrint('getAvailableBiometrics PlatformException: ${e.code} ${e.message}');
      return [];
    } catch (e) {
      debugPrint('getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Helper to check device support API-level etc.
  Future<bool> isDeviceSupported() async {
    try {
      final supported = await _auth.isDeviceSupported();
      debugPrint('isDeviceSupported -> $supported');
      return supported;
    } catch (e) {
      debugPrint('isDeviceSupported error: $e');
      return false;
    }
  }

  /// Debug helper: returns a map summarizing biometric state (for logs)
  Future<Map<String, dynamic>> debugBiometricStatus() async {
    try {
      final supported = await isDeviceSupported();
      final canCheck = await checkBiometricAvailability();
      final available = await getAvailableBiometrics();
      final isAvailable = await isBiometricAvailable();
      
      return {
        'isDeviceSupported': supported,
        'canCheckBiometrics': canCheck,
        'availableBiometrics': available,
        'isBiometricAvailable': isAvailable,
      };
    } catch (e) {
      debugPrint('debugBiometricStatus error -> $e');
      return {'error': e.toString()};
    }
  }

  /// Main authenticate method that returns detailed result:
  /// {'success': bool, 'message': String, 'code': optionalPlatformCode}
  Future<Map<String, dynamic>> authenticateWithBiometricsDetailed({String? localizedReason}) async {
    final reason = localizedReason ?? 'Scan your fingerprint to authenticate';
    try {
      // Check if biometric is available before attempting authentication
      final biometricAvailable = await isBiometricAvailable();
      if (!biometricAvailable) {
        return {
          'success': false,
          'message': 'Biometric authentication is not available on this device.',
          'code': 'NotAvailable'
        };
      }

      // Attempt authentication (the system dialog will show)
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      debugPrint('authenticate result -> $didAuthenticate');
      return {
        'success': didAuthenticate,
        'message': didAuthenticate ? 'OK' : 'Authentication returned false (user canceled or failed)',
        'code': didAuthenticate ? 'OK' : 'AuthReturnedFalse'
      };
    } on PlatformException catch (e) {
      debugPrint('authenticate PlatformException -> code=${e.code} msg=${e.message}');

      // Map known platform exception codes to friendly messages
      String friendly;
      switch (e.code) {
        case 'NotAvailable':
          friendly = 'Biometric hardware or credentials not available on this device.';
          break;
        case 'NotEnrolled':
          friendly = 'No biometric enrolled. Please enroll fingerprint or Face ID in device settings.';
          break;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          friendly = 'Biometric locked out due to too many failed attempts. Please unlock device or use device passcode.';
          break;
        case 'PasscodeNotSet':
          friendly = 'Device passcode is not set. Set a device passcode to enable biometric authentication.';
          break;
        case 'no_fragment_activity':
        case 'NoFragmentActivity':
        case 'no_activity':
          friendly = 'Activity not FragmentActivity. Ensure MainActivity extends FlutterFragmentActivity (see docs). ${e.message ?? ''}';
          break;
        default:
          friendly = 'PlatformException: ${e.code} ${e.message}';
      }

      return {'success': false, 'message': friendly, 'code': e.code};
    } catch (e) {
      debugPrint('authenticate error -> $e');
      return {'success': false, 'message': e.toString(), 'code': 'UnknownError'};
    }
  }
}