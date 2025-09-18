import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationProvider with ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();

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

  /// Returns Map {'success': bool, 'message': String}
  Future<Map<String, dynamic>> authenticateWithBiometricsDetailed({String? localizedReason}) async {
    final reason = localizedReason ?? 'Scan your fingerprint to authenticate';
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      debugPrint('authenticate result -> $didAuthenticate');
      return {'success': didAuthenticate, 'message': didAuthenticate ? 'OK' : 'Authentication returned false'};
    } on PlatformException catch (e) {
      debugPrint('authenticate PlatformException -> code=${e.code} msg=${e.message}');
      return {'success': false, 'message': 'PlatformException: ${e.code} ${e.message}'};
    } catch (e) {
      debugPrint('authenticate error -> $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
