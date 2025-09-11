import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onboarding_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboarding_app/screens/myjourney/my_journey_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isHeaderExpanded = false;
  Map<String, dynamic>? _userData;
  bool _isCheckingVerification = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // Jangan tampilkan dialog verifikasi di sini karena akan mengganggu auto login
    // Pemeriksaan verifikasi sebaiknya dilakukan setelah UI ditampilkan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmailVerification();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleHeaderExpansion() {
    setState(() {
      _isHeaderExpanded = !_isHeaderExpanded;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      // Email not verified - show verification dialog
      _showVerificationDialog(context, user);
    }

    setState(() {
      _isCheckingVerification = false;
    });
  }

  void _showVerificationDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Not Verified'),
          content: const Text(
              'Please verify your email address before using the app. '
              'Check your inbox for a verification email.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Resend Verification'),
              onPressed: () async {
                try {
                  await user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(224, 124, 124, 1);

    // Show loading indicator while checking verification
    if (_isCheckingVerification) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pengguna dengan kemampuan stretch
              _buildExpandableUserHeader(primaryColor),
              const SizedBox(height: 24),

              // Bahagian Quick Action
              _buildQuickActions(primaryColor),
              const SizedBox(height: 24),

              // Bahagian Berita
              _buildNewsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(primaryColor),
    );
  }

  // Widget untuk header pengguna yang dapat di-expand
  Widget _buildExpandableUserHeader(Color primaryColor) {
    return GestureDetector(
      onTap: _toggleHeaderExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _isHeaderExpanded
            ? Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                          Icons.person, _userData?['fullName'] ?? "Loading..."),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          Icons.email, _userData?['email'] ?? "Loading..."),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.phone,
                          _userData?['phoneNumber'] ?? "Loading..."),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.business,
                          "${_userData?['workUnit'] ?? "Loading"} | ${_userData?['workplace'] ?? "Loading"}"),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          Icons.work, _userData?['workType'] ?? "Loading..."),
                      const SizedBox(height: 12),
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hello,",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            _userData?['username'] ?? "Loading...",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
      ),
    );
  }

  // Widget untuk baris detail (di expanded state)
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // -----------------------------
  // Quick Actions - design with 3 columns (more compact)
  // -----------------------------
  Widget _buildQuickActions(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Action",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Kolom 1: kosong, Learning Hub, Facilities, kosong
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      _buildSmallActionCompact(
                          SvgPicture.asset("assets/svgs/Learning Hub.svg"),
                          "Learning\nHub",
                          primaryColor),
                      const SizedBox(height: 20),
                      _buildSmallActionCompact(
                          SvgPicture.asset("assets/svgs/Facilities.svg"),
                          "Facilities\n",
                          primaryColor),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),

                // Kolom 2: My Document, My Journey, Task Manager
                Expanded(
                  child: Column(
                    children: [
                      _buildSmallActionCompact(
                          SvgPicture.asset("assets/svgs/My Document.svg"),
                          "My\nDocument",
                          primaryColor),
                      const SizedBox(height: 20),
                      _buildCenterJourneyCompact(primaryColor),
                      const SizedBox(height: 20),
                      _buildSmallActionCompact(
                          SvgPicture.asset("assets/svgs/Task Manager.svg"),
                          "Task\nManager",
                          primaryColor),
                    ],
                  ),
                ),

                // Kolom 3: kosong, Meet the Team, Buddy Chat, kosong
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      _buildSmallActionCompact(
                          SvgPicture.asset("assets/svgs/Meet the Team.svg"),
                          "Meet the\nTeam",
                          primaryColor),
                      const SizedBox(height: 20),
                      _buildSmallActionCompact(
                          SvgPicture.asset("assets/svgs/Buddy Chat.svg"),
                          "Buddy\nChat",
                          primaryColor),
                      const SizedBox(height: 50),
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

  // Compact small action item
  Widget _buildSmallActionCompact(Widget icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // TODO: handle navigation
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 50, height: 50, child: icon),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Compact center big circular "My Journey"
  Widget _buildCenterJourneyCompact(Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyJourneyScreen()),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(245, 245, 247, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 0),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 60, color: Colors.white),
                      Text(
                        "My\nJourney",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // News section
  // -----------------------------
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "News",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/news_background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "New App Onboard X: Cleaner, easier to use, and faster to navigate.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavBar(Color primaryColor) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: const Color.fromRGBO(224, 124, 124, 1),
      buttonBackgroundColor: primaryColor,
      height: 60,
      items: const <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
        Icon(Icons.settings, size: 30, color: Colors.white),
      ],
      index: _selectedIndex,
      onTap: _onItemTapped,
      letIndexChange: (index) => true,
    );
  }
}
