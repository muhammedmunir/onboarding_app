// learning_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'learning_hub_create_screen.dart';
import 'learning_hub_detail_screen.dart';
import 'learning_hub_complete_screen.dart';
import 'learning_hub_inprogress_screen.dart';
import 'learning_hub_all_screen.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // trigger rebuild to re-filter results inside StreamBuilder
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final learningsStream = FirebaseFirestore.instance
        .collection('learnings')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(224, 124, 124, 1),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LearningHubCreateScreen()),
          ).then((newLearning) {
            if (newLearning != null && newLearning is Map && newLearning['id'] != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Learning created (id: ${newLearning['id']})')),
              );
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: learningsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading learnings: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Convert documents to normalized map list
          final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          List<Map<String, dynamic>> allCourses = docs.map((d) {
            final data = d.data() ?? <String, dynamic>{};
            final title = (data['title'] as String?) ?? 'Untitled';
            final description = (data['description'] as String?) ?? '';
            final imageUrl = (data['coverImageUrl'] as String?) ??
                'https://cdn-icons-png.flaticon.com/512/888/888883.png';
            final progressNum = data['progress'];
            double progress = 0.0;
            if (progressNum is num) {
              progress = progressNum.toDouble();
            } else {
              try {
                progress = double.parse((progressNum ?? '0').toString());
              } catch (_) {
                progress = 0.0;
              }
            }
            if (progress < 0) progress = 0.0;
            if (progress > 1) progress = 1.0;

            String category;
            if (progress >= 1.0) {
              category = 'complete';
            } else if (progress > 0.0) {
              category = 'inprogress';
            } else {
              category = 'notstarted';
            }

            return {
              'id': d.id,
              'title': title,
              'description': description,
              'imageUrl': imageUrl,
              'progress': progress,
              'category': category,
              'raw': data,
            };
          }).toList();

          // Apply search filter (client side)
          final query = _searchController.text.trim().toLowerCase();
          List<Map<String, dynamic>> filtered = allCourses;
          if (query.isNotEmpty) {
            filtered = allCourses.where((course) {
              final title = (course['title'] as String).toLowerCase();
              final description = (course['description'] as String).toLowerCase();
              return title.contains(query) || description.contains(query);
            }).toList();
          }

          final completeCourses = filtered.where((c) => c['category'] == 'complete').toList();
          final inProgressCourses = filtered.where((c) => c['category'] == 'inprogress').toList();
          final allCoursesFiltered = filtered;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                if (completeCourses.isNotEmpty) ...[
                  _buildSectionHeader('Complete', true, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LearningHubCompleteScreen()),
                    );
                  }),
                  const SizedBox(height: 12.0),
                  ...completeCourses.map((course) => _buildLearningItemFromMap(course)).toList(),
                  const SizedBox(height: 24.0),
                ],

                if (inProgressCourses.isNotEmpty) ...[
                  _buildSectionHeader('In progress', true, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LearningHubInprogressScreen()),
                    );
                  }),
                  const SizedBox(height: 12.0),
                  ...inProgressCourses.map((course) => _buildLearningItemFromMap(course)).toList(),
                  const SizedBox(height: 24.0),
                ],

                if (allCoursesFiltered.isNotEmpty) ...[
                  _buildSectionHeader('All learning', true, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LearningHubAllScreen()),
                    );
                  }),
                  const SizedBox(height: 12.0),
                  ...allCoursesFiltered.map((course) => _buildLearningItemFromMap(course)).toList(),
                ],

                if (filtered.isEmpty) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No courses found',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showSeeAll, VoidCallback? onSeeAllPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAllPressed,
            child: const Text(
              'See All',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // MAIN: show per-user progress by listening to the user's progress doc for each learning
  Widget _buildLearningItemFromMap(Map<String, dynamic> course) {
    final title = course['title'] as String;
    final subtitle = course['description'] as String;
    final fallbackProgress = (course['progress'] as double?) ?? 0.0;
    final imageUrl = course['imageUrl'] as String;
    final raw = course['raw'] as Map<String, dynamic>;
    final learningId = course['id'] as String;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // not signed in -> show fallback progress from root doc
      return _learningItemCard(title, subtitle, imageUrl, fallbackProgress, raw, learningId);
    }

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
          final data = snap.data!.data();
          final completed = data?['completedLessons'];
          int completedCount = 0;
          if (completed is List) completedCount = completed.length;

          int totalLessons = 0;
          try {
            if (raw['lessons'] is List) totalLessons = (raw['lessons'] as List).length;
          } catch (_) {
            totalLessons = 0;
          }

          if (totalLessons > 0) {
            displayProgress = (completedCount / totalLessons).clamp(0.0, 1.0).toDouble();
          } else {
            displayProgress = fallbackProgress;
          }
        }
        return _learningItemCard(title, subtitle, imageUrl, displayProgress, raw, learningId);
      },
    );
  }

  // Helper to build the card (reused whether we use fallback or user-specific progress)
  Widget _learningItemCard(String title, String subtitle, String imageUrl, double progress,
      Map<String, dynamic> raw, String learningId) {
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
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image with fallback
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
                        color: Colors.grey[100],
                        alignment: Alignment.center,
                        child: const Icon(Icons.description, color: Colors.grey),
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
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(
              value: (progress.clamp(0.0, 1.0)).toDouble(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 8.0,
            ),
            const SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progress >= 1.0 ? Colors.green : Colors.blue,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
