import 'package:flutter/material.dart';
import 'package:onboarding_app/services/theme_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let the app bar styling come from the theme (no hard-coded colors)
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // keep transparent if you want
        automaticallyImplyLeading: false,
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

          // Listen to the themeNotifier to update the UI in real time
          ValueListenableBuilder<ThemeMode>(
  valueListenable: themeNotifier,
  builder: (context, ThemeMode mode, _) {
    final isDark = mode == ThemeMode.dark;
    return SwitchListTile(
      title: const Text('Dark Mode'),
      secondary: Icon(
        isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      ),
      activeColor: const Color.fromRGBO(224, 124, 124, 1), // warna toggle bila ON
      value: isDark,
      onChanged: (value) {
        themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
      },
    );
  },
),

          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).iconTheme.color),
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          // keep using primary color for section headers — that works in both themes
          color: Color.fromRGBO(224, 124, 124, 1),
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
      leading: Icon(icon), // color now follows theme's iconTheme
      title: Text(title), // color follows theme text
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}