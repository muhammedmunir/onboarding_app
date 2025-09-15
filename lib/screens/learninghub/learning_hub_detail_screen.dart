import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LearningHubDetailScreen extends StatefulWidget {
  final String learningId; // FIRESTORE DOC ID for the learning
  final String courseTitle;
  final String courseDescription;
  final double progress; // fallback/global progress (kept for compatibility)
  final Map<String, dynamic> rawData;

  const LearningHubDetailScreen({
    super.key,
    required this.learningId,
    required this.courseTitle,
    required this.courseDescription,
    required this.progress,
    required this.rawData,
  });

  @override
  State<LearningHubDetailScreen> createState() => _LearningHubDetailScreenState();
}

class _LearningHubDetailScreenState extends State<LearningHubDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatCreatedAt(dynamic rawCreatedAt) {
    try {
      if (rawCreatedAt == null) return 'Unknown date';
      if (rawCreatedAt is Timestamp) {
        final dt = rawCreatedAt.toDate();
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      if (rawCreatedAt is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
        return '${dt.day}/${dt.month}/${dt.year}';
      }
      if (rawCreatedAt is String) return rawCreatedAt;
      if (rawCreatedAt is DateTime) {
        final dt = rawCreatedAt;
        return '${dt.day}/${dt.month}/${dt.year}';
      }
      return rawCreatedAt.toString();
    } catch (e) {
      return 'Unknown date';
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL: $e')),
      );
    }
  }

  // Toggle completed state for current user for lesson index `idx`
  Future<void> _toggleCompleted(int idx, bool currentlyCompleted) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to track progress')),
      );
      return;
    }

    final userProgRef = _firestore
        .collection('learnings')
        .doc(widget.learningId)
        .collection('userProgress')
        .doc(user.uid);

    try {
      if (currentlyCompleted) {
        // remove index
        await userProgRef.set({
          'completedLessons': FieldValue.arrayRemove([idx]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // add index
        await userProgRef.set({
          'completedLessons': FieldValue.arrayUnion([idx]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // success feedback (UI auto-updates via stream)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentlyCompleted ? 'Marked as not completed' : 'Marked as completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverImage = (widget.rawData['coverImageUrl'] as String?) ??
        'https://cdn-icons-png.flaticon.com/512/888/888883.png';
    final createdAt = _formatCreatedAt(widget.rawData['createdAt']);
    final lessonsRaw = widget.rawData['lessons'];
    List<Map<String, dynamic>> lessons = [];

    if (lessonsRaw is List) {
      for (final item in lessonsRaw) {
        if (item is Map<String, dynamic>) {
          lessons.add(item);
        } else if (item is Map) {
          lessons.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final totalLessons = lessons.length;

    final user = _auth.currentUser;
    // stream of user's progress doc
    final userProgressStream = (user != null)
        ? _firestore
            .collection('learnings')
            .doc(widget.learningId)
            .collection('userProgress')
            .doc(user.uid)
            .snapshots()
        : const Stream.empty();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Overview',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userProgressStream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
        builder: (context, snap) {
          // derive completedIndexes set for current user
          Set<int> completedIndexes = {};
          if (snap.hasData && snap.data!.exists) {
            final data = snap.data!.data();
            final completed = (data?['completedLessons']);
            if (completed is List) {
              for (final item in completed) {
                try {
                  completedIndexes.add(int.parse(item.toString()));
                } catch (_) {
                  // ignore non-int values
                }
              }
            }
          }

          final completedCount = completedIndexes.length;
          final userProgress = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    coverImage,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),

                // Title & meta
                Text(
                  widget.courseTitle,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.courseDescription,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Created: $createdAt',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    if (widget.rawData['createdBy'] != null)
                      Text(
                        ' • By ${widget.rawData['createdBy']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                  ],
                ),

                const SizedBox(height: 24.0),

                // Lessons header + user progress summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lessons',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${completedCount}/${totalLessons} completed',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                // Lessons list
                if (lessons.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No lessons found for this course.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  Column(
                    children: lessons.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final lesson = entry.value;
                      final lessonTitle = (lesson['title'] as String?) ?? 'Lesson ${idx + 1}';
                      final lessonDesc = (lesson['description'] as String?) ?? '';
                      final contentType = (lesson['contentType'] as String?) ?? '';
                      final contentUrl = (lesson['contentUrl'] as String?) ?? '';

                      final completed = completedIndexes.contains(idx);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lessonTitle,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                // Completed badge (per user)
                                if (completed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.green.withOpacity(0.25)),
                                    ),
                                    child: const Text(
                                      'Completed',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            if (lessonDesc.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                lessonDesc,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (contentType.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      contentType,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                if (contentUrl.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _openUrl(context, contentUrl),
                                    icon: const Icon(Icons.open_in_new, size: 16),
                                    label: const Text('Open'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(224, 124, 124, 1),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                if (contentUrl.isEmpty)
                                  Text(
                                    'No content URL',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                  ),
                                const Spacer(),
                                // Toggle completion button (only for authenticated user)
                                if (user != null)
                                  IconButton(
                                    onPressed: () => _toggleCompleted(idx, completed),
                                    icon: Icon(
                                      completed ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: completed ? Colors.green : Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24.0),

                // Progress Section (use user's progress when logged in, otherwise fallback to widget.progress)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: user != null ? userProgress.clamp(0.0, 1.0) : widget.progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 10.0,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${((user != null ? userProgress : widget.progress) * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
