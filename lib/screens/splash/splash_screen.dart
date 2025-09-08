import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onboarding_app/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi ke skrin log masuk selepas 3 saat
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_Splash.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Logo OnboardX di tengah
            Center(
              child: Image.asset(
                "assets/images/logo_OnboardingX.png",
                width: 300,
              ),
            ),

            // Logo TNB di bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30), // jarak dari bawah
                child: Image.asset(
                  "assets/images/logo_tnb.png",
                  width: 170,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
