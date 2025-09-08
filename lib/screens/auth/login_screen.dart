import 'package:flutter/material.dart';
import 'package:onboarding_app/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background hexagon
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_Splash.jpg"),
              ),
            ),
          ),

          // Semi circle atas
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size.width,
              height: 200,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(224, 124, 124, 1),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(300),
                ),
              ),
            ),
          ),

          // Semi circle bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 200,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(224, 124, 124, 1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(300),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Logo OnboardingX (atas)
                      Center(
                        child: Image.asset(
                          "assets/images/logo_OnboardingX.png",
                          width: 220,
                        ),
                      ),

                      const SizedBox(height: 150),

                      // Kad Login
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // Email
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                border: UnderlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                border: UnderlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Button Login
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(224, 124, 124, 1),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 140),
                    ],
                  ),
                ),

                // Logo TNB bawah center
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Image.asset(
                      "assets/images/logo_tnb.png",
                      width: 170,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}