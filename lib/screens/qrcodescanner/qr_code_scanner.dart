import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  Barcode? result;
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
    qrController?.dispose();
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
      final doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() => _currentUserData = doc.data()! as Map<String, dynamic>);
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => qrController = controller);
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && _scanning) {
        setState(() {
          result = scanData;
          _scanning = false;
        });
        _handleScannedData(scanData.code!);
      }
    });
  }

  Future<void> _handleScannedData(String scannedUid) async {
    if (scannedUid == _auth.currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't scan your own QR code")),
      );
      return;
    }

    setState(() => _loading = true);
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData['fullName'] ?? 'N/A'}'),
            Text('Username: ${userData['username'] ?? 'N/A'}'),
            Text('Email: ${userData['email'] ?? 'N/A'}'),
            Text('Phone: ${userData['phoneNumber'] ?? 'N/A'}'),
            Text('Work: ${userData['workType'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => _saveContact(userData),
            child: const Text('Save Contact'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContact(Map<String, dynamic> userData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts')
        .doc(userData['uid'])
        .set(userData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact saved successfully')),
    );
    Navigator.pop(context);
  }

  void _resetScanner() {
    setState(() {
      result = null;
      _scanning = true;
    });
    qrController?.resumeCamera();
  }

  Widget _buildScannerTab() {
    if (!_permissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Camera permission required'),
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
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.red,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 250,
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildMyQrTab() {
    if (_currentUserData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: _auth.currentUser?.uid ?? '',
            version: QrVersions.auto,
            size: 200,
            gapless: false,
            embeddedImage: NetworkImage(
                _currentUserData!['profileImageUrl'] ?? ''),
            embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
          ),
          const SizedBox(height: 20),
          Text(
            _currentUserData!['fullName'] ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            _currentUserData!['username'] ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Scan this QR code to add me as a contact',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
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