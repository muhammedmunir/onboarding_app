import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileDetailScreen extends StatelessWidget {
  const UserProfileDetailScreen({super.key});

  // Function to launch email
  _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch email';
    }
  }

  // Function to launch phone call
  _launchPhone(String phone) async {
    final Uri params = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch phone';
    }
  }

  // Function to launch WhatsApp
  _launchWhatsApp(String phone) async {
    // Remove any non-digit characters except +
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    final Uri params = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: cleanedPhone,
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meet The Team',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(224, 124, 124, 1),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'User Profile Detail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromRGBO(224, 124, 124, 1),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Name Section
            _buildProfileSection(
              title: 'Name',
              content: 'Datuk Ir. Megat Jalaluddin Bin Megat Hassan',
            ),
            
            // Position Section
            _buildProfileSection(
              title: 'Position',
              content: 'President/Ketua Pegawai Eksekutif (CEO)',
            ),
            
            // Email Section
            _buildEmailSection(
              title: 'Email',
              content: 'Ceo@tnb.com.my',
            ),
            
            // Phone Section
            _buildPhoneSection(
              title: 'Phone',
              content: '+60 00000000000',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(224, 124, 124, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmailSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(224, 124, 124, 1),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _launchEmail(content),
          child: Row(
            children: [
              const Icon(Icons.email, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPhoneSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(224, 124, 124, 1),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // WhatsApp button
            InkWell(
              onTap: () => _launchWhatsApp(content),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.message,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone call button
            InkWell(
              onTap: () => _launchPhone(content),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}