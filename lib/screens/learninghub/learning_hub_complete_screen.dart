import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'learning_hub_detail_screen.dart';

class LearningHubCompleteScreen extends StatefulWidget {
  const LearningHubCompleteScreen({super.key});

  @override
  State<LearningHubCompleteScreen> createState() =>
      _LearningHubCompleteScreenState();
}

class _LearningHubCompleteScreenState extends State<LearningHubCompleteScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _shouldRefresh = false;
  late Stream<List<Map<String, dynamic>>> _completeLearningsStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addObserver(this);
    _setupStream();
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

  void _setupStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _completeLearningsStream = _getCompleteLearningsStream(user.uid);
    } else {
      _completeLearningsStream = Stream.value([]);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _shouldRefresh = false;
      _setupStream(); // Re-setup the stream to force refresh
    });
  }

  Stream<List<Map<String, dynamic>>> _getCompleteLearningsStream(
      String userId) {
    final allLearningsStream = FirebaseFirestore.instance
        .collection('learnings')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return allLearningsStream.asyncMap((querySnapshot) async {
      final futures = querySnapshot.docs.map((doc) {
        return _getLearningWithUserProgressIfComplete(doc, userId);
      }).toList();

      final results = await Future.wait(futures);
      return results
          .where((item) => item != null)
          .cast<Map<String, dynamic>>()
          .toList();
    });
  }

  Future<Map<String, dynamic>?> _getLearningWithUserProgressIfComplete(
      QueryDocumentSnapshot learningDoc, String userId) async {
    final learningId = learningDoc.id;
    final rawData = learningDoc.data() as Map<String, dynamic>;

    final userProgressDoc = await FirebaseFirestore.instance
        .collection('learnings')
        .doc(learningId)
        .collection('userProgress')
        .doc(userId)
        .get();

    double progress = 0.0;
    if (userProgressDoc.exists) {
      final data = userProgressDoc.data();
      final completed = data?['completedLessons'];
      int completedCount = (completed is List) ? completed.length : 0;
      int totalLessons = (rawData['lessons'] is List)
          ? (rawData['lessons'] as List).length
          : 0;

      if (totalLessons > 0) {
        progress = (completedCount / totalLessons).clamp(0.0, 1.0);
      }
    }

    if (progress >= 1.0) {
      return {
        'id': learningDoc.id,
        'title': (rawData['title'] as String?) ?? 'Untitled',
        'description': (rawData['description'] as String?) ?? '',
        'imageUrl': rawData['coverImageUrl'],
        'progress': progress,
        'raw': rawData,
      };
    } else {
      return null;
    }
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
                    hintText: 'Search Completed Courses...',
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
                'Completed Courses',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),

              // Daftar kursus
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _completeLearningsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final allCompleteCourses = snapshot.data ?? [];

                    // Terapkan filter pencarian
                    final query = _searchController.text.trim().toLowerCase();
                    final filteredCourses = allCompleteCourses.where((course) {
                      if (query.isEmpty) return true;
                      final title =
                          (course['title'] as String? ?? '').toLowerCase();
                      final description =
                          (course['description'] as String? ?? '').toLowerCase();
                      return title.contains(query) || description.contains(query);
                    }).toList();

                    if (filteredCourses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No completed courses found.',
                          style: TextStyle(fontSize: 18.0, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 0, bottom: 16.0),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        return _learningItemCard(
                          course['title'] as String,
                          course['description'] as String,
                          course['imageUrl'] as String,
                          course['progress'] as double,
                          course['raw'] as Map<String, dynamic>,
                          course['id'] as String,
                        );
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
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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