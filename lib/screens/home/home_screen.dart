// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(224, 124, 124, 1);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pengguna
              _buildUserHeader(primaryColor),
              const SizedBox(height: 24),

              // Bahagian Quick Action (seperti gambar)
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

  // Widget untuk header pengguna
  Widget _buildUserHeader(Color primaryColor) {
    return Container(
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage("assets/images/profile_pic.jpg"),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello,",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                "Siti Zubaidah",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: logout action
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 28),
          ),
        ],
      ),
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
          padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 40), // Spacer untuk kosong atas
                    _buildSmallActionCompact(Icons.school, "Learning\nHub", primaryColor),
                    const SizedBox(height: 12),
                    _buildSmallActionCompact(Icons.apartment, "Facilities\n", primaryColor),
                    const SizedBox(height: 40), // Spacer untuk kosong bawah
                  ],
                ),
              ),

              // Kolom 2: My Document, My Journey, Task Manager
              Expanded(
                child: Column(
                  children: [
                    _buildSmallActionCompact(Icons.description, "My\nDocument", primaryColor),
                    const SizedBox(height: 12),
                    _buildCenterJourneyCompact(primaryColor),
                    const SizedBox(height: 12),
                    _buildSmallActionCompact(Icons.task_alt, "Task\nManager", primaryColor),
                  ],
                ),
              ),

              // Kolom 3: kosong, Meet the Team, Buddy Chat, kosong
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 40), // Spacer untuk kosong atas
                    _buildSmallActionCompact(Icons.people, "Meet the\nTeam", primaryColor),
                    const SizedBox(height: 12),
                    _buildSmallActionCompact(Icons.chat_bubble, "Buddy\nChat", primaryColor),
                    const SizedBox(height: 40), // Spacer untuk kosong bawah
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
Widget _buildSmallActionCompact(IconData icon, String label, Color color) {
  return GestureDetector(
    onTap: () {
      // TODO: handle navigation
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: color), // Ukuran icon tetap
        const SizedBox(height: 6), // Jarak lebih kecil
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11), // Font lebih kecil
        ),
      ],
    ),
  );
}

// Compact center big circular "My Journey"
Widget _buildCenterJourneyCompact(Color color) {
  return GestureDetector(
    onTap: () {
      // TODO: My Journey action
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular elevated button (lebih kecil)
        Container(
          width: 90, // Lebih kecil dari sebelumnya
          height: 90, // Lebih kecil dari sebelumnya
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
                Icon(Icons.flag, size: 50, color: Colors.white), // Ukuran icon tetap
                Text(
                  "My\nJourney",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white), // Font lebih kecil
                )
              ],
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
            itemCount: 3, // Bilangan berita
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
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
