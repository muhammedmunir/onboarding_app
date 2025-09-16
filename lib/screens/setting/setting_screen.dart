import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        // leading: Center(
        //   child: InkWell(
        //     borderRadius: BorderRadius.circular(8),
        //     onTap: () => Navigator.of(context).pop(),
        //     child: Container(
        //       width: 40,
        //       height: 40,
        //       decoration: BoxDecoration(
        //         color: const Color.fromRGBO(224, 124, 124, 1),
        //         borderRadius: BorderRadius.circular(6),
        //       ),
        //       alignment: Alignment.center,
        //       child: const Icon(
        //         Icons.arrow_back_ios_new,
        //         color: Colors.white,
        //         size: 16,
        //       ),
        //     ),
        //   ),
        // ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Account'),
          _buildListTile(
            title: 'Manage Your Account',
            icon: Icons.account_circle_outlined,
            onTap: () {
              // Navigate to account management screen
            },
          ),
          _buildSectionHeader('Preferences'),
          _buildListTile(
            title: 'Device Permission',
            icon: Icons.perm_device_info_outlined,
            onTap: () {
              // Navigate to device permission screen
            },
          ),
          _buildListTile(
            title: 'Language and Translations',
            icon: Icons.language_outlined,
            onTap: () {
              // Navigate to language selection screen
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(
              _darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              // Implement dark mode toggle logic here
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 16),
                const Text('Version'),
                const Spacer(),
                Text(
                  '1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}