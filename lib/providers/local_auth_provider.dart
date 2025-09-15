import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationProvider with ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> checkBiometricAvailability() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Jika anda mahu reason custom, pass localizedReason.
  Future<bool> authenticateWithBiometrics({String? localizedReason}) async {
    try {
      final reason = localizedReason ?? 'Scan your fingerprint to authenticate';
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
