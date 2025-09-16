import 'package:flutter/material.dart';

class DocumentManagerScreen extends StatelessWidget {
  const DocumentManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background for the whole screen
      appBar: AppBar(
        title: const Text(
          'Task Manager',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Required Documents Section
            Text(
              'Required Documents',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const DocumentCard(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Lampiran A',
              subtitle: 'Uploaded',
              subtitleColor: Colors.green,
            ),
            const SizedBox(height: 12),
            DocumentCard(
              icon: Icons.arrow_circle_up,
              iconColor: Colors.red,
              title: 'Sijil Tanggung Diri',
              subtitle: 'Upload in Progress',
              subtitleColor: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            DocumentCard(
              icon: Icons.add_circle,
              iconColor: Colors.grey,
              title: 'Penyata Bank',
              subtitle: 'Upload the required files',
              subtitleColor: Colors.grey[600],
            ),

            const SizedBox(height: 32),

            // Private Details and Certs Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Private Details and Certs',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle View All for Private Details
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const DocumentCard(
              icon: Icons.person,
              iconColor: Colors.black54,
              title: 'Identity Card (IC)',
              subtitle: 'Upload Required',
              subtitleColor: Colors.red,
            ),
            const SizedBox(height: 12),
            DocumentCard(
              icon: Icons.drive_eta, // Using a car icon for driving license
              iconColor: Colors.black54,
              title: 'Driving License',
              subtitle: 'Optional',
              subtitleColor: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            DocumentCard(
              icon: Icons.badge, // Using a badge icon for certificates
              iconColor: Colors.black54,
              title: 'Certificates',
              subtitle: 'Optional',
              subtitleColor: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final bool showViewButton;

  const DocumentCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.showViewButton = true, // Most cards have a view button
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove default card margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1, // Subtle shadow
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1), // Lighter background for the icon circle
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor ?? Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (showViewButton) // Conditionally show the View button
              SizedBox(
                height: 30, // Control button height
                child: OutlinedButton(
                  onPressed: () {
                    // Handle view button press for this document
                    print('View ${title}');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    visualDensity: VisualDensity.compact, // Make button smaller
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 13)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}