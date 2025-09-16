import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'learning_hub_detail_screen.dart';

class LearningHubAllScreen extends StatefulWidget {
  const LearningHubAllScreen({super.key});

  @override
  State<LearningHubAllScreen> createState() => _LearningHubAllScreenState();
}

class _LearningHubAllScreenState extends State<LearningHubAllScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _shouldRefresh = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _shouldRefresh = true;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _refreshData() async {
    setState(() {
      _shouldRefresh = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && _shouldRefresh) {
          _refreshData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Learning Hub',
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Now...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Section Header
              const Text(
                'All Courses',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),

              // Daftar kursus di dalam Expanded agar bisa di-scroll
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('learnings')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allDocs = snapshot.data?.docs ?? [];

                    // Terapkan filter pencarian
                    final query = _searchController.text.trim().toLowerCase();
                    final filteredDocs = allDocs.where((doc) {
                      if (query.isEmpty) {
                        return true; // Tampilkan semua jika pencarian kosong
                      }
                      final data = doc.data();
                      final title =
                          (data['title'] as String? ?? '').toLowerCase();
                      final description =
                          (data['description'] as String? ?? '').toLowerCase();
                      return title.contains(query) || description.contains(query);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No courses found.',
                          style: TextStyle(fontSize: 18.0, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 0, bottom: 16.0),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        return _buildLearningItem(doc);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun satu item list. Widget ini memiliki StreamBuilder sendiri
  /// untuk mendapatkan progres spesifik pengguna secara real-time.
  Widget _buildLearningItem(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final title = (data['title'] as String?) ?? 'Untitled';
    final subtitle = (data['description'] as String?) ?? '';
    final imageUrl = data['coverImageUrl'];
    final learningId = doc.id;

    // Progres fallback dari dokumen root jika tersedia
    double fallbackProgress = 0.0;
    final progressNum = data['progress'];
    if (progressNum is num) {
      fallbackProgress = progressNum.toDouble();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Jika tidak ada user, tampilkan kartu dengan progres fallback
      return _learningItemCard(
          title, subtitle, imageUrl, fallbackProgress, data, learningId);
    }

    // Untuk pengguna yang login, dengarkan dokumen progres spesifik mereka
    final userProgStream = FirebaseFirestore.instance
        .collection('learnings')
        .doc(learningId)
        .collection('userProgress')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userProgStream,
      builder: (context, snap) {
        double displayProgress = fallbackProgress;
        if (snap.hasData && snap.data!.exists) {
          final progressData = snap.data!.data();
          final completed = progressData?['completedLessons'];
          int completedCount = (completed is List) ? completed.length : 0;
          int totalLessons =
              (data['lessons'] is List) ? (data['lessons'] as List).length : 0;

          if (totalLessons > 0) {
            displayProgress = (completedCount / totalLessons).clamp(0.0, 1.0);
          }
        }
        return _learningItemCard(
            title, subtitle, imageUrl, displayProgress, data, learningId);
      },
    );
  }

  /// Widget kartu yang dapat digunakan kembali untuk menampilkan detail item pembelajaran.
  Widget _learningItemCard(String title, String subtitle, String imageUrl,
      double progress, Map<String, dynamic> raw, String learningId) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LearningHubDetailScreen(
              learningId: learningId,
              courseTitle: title,
              courseDescription: subtitle,
              progress: progress,
              rawData: raw,
            ),
          ),
        ).then((_) {
          setState(() {
            _shouldRefresh = true;
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (progress.clamp(0.0, 1.0)).toDouble(),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.green : Colors.blue,
                      ),
                      minHeight: 10.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progress >= 1.0
                        ? Colors.green
                        : progress > 0.0
                            ? Colors.blue
                            : Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}