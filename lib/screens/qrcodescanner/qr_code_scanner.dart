import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanning = true;
  bool _loading = false;
  bool _permissionGranted = false;

  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkCameraPermission();
    _fetchCurrentUserData();
  }

  @override
  void dispose() {
    cameraController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
    } else {
      final result = await Permission.camera.request();
      setState(() => _permissionGranted = result.isGranted);
    }
  }

  Future<void> _fetchCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() => _currentUserData = doc.data()! as Map<String, dynamic>);
      }
    }
  }

  void _handleBarcode(BarcodeCapture barcode) {
    if (!_scanning) return;
    
    final String? scannedUid = barcode.barcodes.first.rawValue;
    if (scannedUid == null) return;

    if (scannedUid == _auth.currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't scan your own QR code")),
      );
      return;
    }

    setState(() {
      _scanning = false;
      _loading = true;
    });

    _processScannedUid(scannedUid);
  }

  Future<void> _processScannedUid(String scannedUid) async {
    try {
      final doc = await _firestore.collection('users').doc(scannedUid).get();
      if (doc.exists) {
        final userData = doc.data()! as Map<String, dynamic>;
        _showUserContactDialog(userData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showUserContactDialog(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Found'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userData['profileImageUrl'] != null)
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userData['profileImageUrl']),
                ),
              const SizedBox(height: 16),
              Text('Name: ${userData['fullName'] ?? 'N/A'}'),
              Text('Username: ${userData['username'] ?? 'N/A'}'),
              Text('Email: ${userData['email'] ?? 'N/A'}'),
              Text('Phone: ${userData['phoneNumber'] ?? 'N/A'}'),
              Text('Work: ${userData['workType'] ?? 'N/A'}'),
              Text('Unit: ${userData['workUnit'] ?? 'N/A'}'),
              Text('Workplace: ${userData['workplace'] ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _saveContact(userData);
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('Save Contact'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContact(Map<String, dynamic> userData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('contacts')
          .doc(userData['uid'])
          .set({
            ...userData,
            'savedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contact: $e')),
      );
    }
  }

  void _resetScanner() {
    setState(() {
      _scanning = true;
    });
    cameraController.start();
  }

  Widget _buildScannerTab() {
    if (!_permissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64),
            const SizedBox(height: 16),
            const Text('Camera permission required'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkCameraPermission,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: _handleBarcode,
          fit: BoxFit.cover,
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Text(
            'Scan a user QR code',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMyQrTab() {
    if (_currentUserData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String uid = _auth.currentUser?.uid ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_currentUserData!['profileImageUrl'] != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage(_currentUserData!['profileImageUrl']),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUserData!['fullName'] ?? 'No Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '@${_currentUserData!['username'] ?? 'nousername'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  QrImageView(
                    data: uid,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan this QR code to add me as a contact',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User ID: ${uid.substring(0, 8)}...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Type', _currentUserData!['workType']),
                  _buildInfoRow('Unit', _currentUserData!['workUnit']),
                  _buildInfoRow('Workplace', _currentUserData!['workplace']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? 'Not specified'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final appBarColor = theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final hintColor = theme.hintColor;
    
    // Colors that adapt to theme
    final primaryColor = isDarkMode 
        ? const Color.fromRGBO(180, 100, 100, 1) // Darker pink for dark mode
        : const Color.fromRGBO(224, 124, 124, 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: hintColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan QR'),
            Tab(icon: Icon(Icons.person), text: 'My QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(),
          _buildMyQrTab(),
        ],
      ),
    );
  }
}