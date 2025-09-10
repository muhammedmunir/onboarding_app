import 'package:flutter/material.dart';
import 'package:onboarding_app/screens/auth/login_screen.dart';
import 'package:onboarding_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firebaseAuth = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _workUnitController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedWorkType;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _clearAllFields() {
    _nameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _workUnitController.clear();
    _workplaceController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedWorkType = null;
    });
  }

  final List<String> _workTypes = [
    'Pre-staff',
    'Bodyshop',
    'Protege',
    'Intern'
  ];

  // Add form key
  final _formKey = GlobalKey<FormState>();

  void _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call AuthService to register with email and password
      User? user = await _firebaseAuth.registerWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': _nameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'workUnit': _workUnitController.text,
          'workplace': _workplaceController.text,
          'workType': _selectedWorkType,
          'emailVerified': false, // Add email verification status
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Send email verification
        await user.sendEmailVerification();

        // Clear all fields after successful registration
        _clearAllFields();

        // Show verification dialog
        _showVerificationDialog(context);
      } else {
        // Registration failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle errors
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

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Verification Required'),
          content: const Text(
              'A verification email has been sent to your email address. '
              'Please verify your email before logging in.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Resend Verification'),
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification email resent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error resending email: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fixed Background hexagon
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_Splash.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Fixed Semi circle atas
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

          // Fixed Semi circle bawah
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

          // Fixed Logo OnboardingX
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/logo_OnboardingX.png",
                width: 200,
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey, // Add form key here
                child: Column(
                  children: [
                    const SizedBox(height: 180),

                    // Register Card
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
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Name
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.trim().split(RegExp(r'\s+')).length >
                                  12) {
                                return 'Username must be max 12 words';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Username",
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
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
                          const SizedBox(height: 15),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Phone Number",
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),

                          // Work Unit
                          TextFormField(
                            controller: _workUnitController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your work unit';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Work Unit",
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Workplace
                          TextFormField(
                            controller: _workplaceController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your workplace';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Workplace",
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.work),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Work Type Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedWorkType,
                            decoration: const InputDecoration(
                              labelText: "Work Type",
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            isExpanded: true,
                            hint: const Text("Select work type"),
                            items: _workTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedWorkType = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a work type';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              // Check minimum 12 characters
                              if (value.length < 12) {
                                return 'Password must be at least 12 characters';
                              }
                              // Check for number
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Password must contain at least one number';
                              }
                              // Check for symbol
                              if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
                                  .hasMatch(value)) {
                                return 'Password must contain at least one symbol';
                              }
                              // Check for uppercase
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password must contain at least one uppercase letter';
                              }
                              // Check for lowercase
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return 'Password must contain at least one lowercase letter';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: const UnderlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              border: const UnderlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Button Register
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(224, 124, 124, 1),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                          const SizedBox(height: 20),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login Now",
                                  style: TextStyle(
                                    color: Color.fromRGBO(224, 124, 124, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}