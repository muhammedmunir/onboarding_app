import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _resetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email using Firebase Auth
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset instructions sent to your email'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error sending reset email. Please try again.';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email address.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address format.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                fit: BoxFit.cover,
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
                      const SizedBox(height: 20),

                      // Logo OnboardingX (atas)
                      Center(
                        child: Image.asset(
                          "assets/images/logo_OnboardingX.png",
                          width: 220,
                        ),
                      ),

                      const SizedBox(height: 100),

                      // Forgot Password Card
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              
                              const Text(
                                "Enter your email address and we'll send you instructions to reset your password.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  border: UnderlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 30),

                              // Reset Password Button
                              _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: _resetPassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(224, 124, 124, 1),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        "Send Reset Instructions",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                              const SizedBox(height: 20),
                              
                              // Back to Login
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "Back to Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(224, 124, 124, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
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