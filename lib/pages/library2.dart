import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soccer_app/pages/video.dart';

//import 'video_detail.dart';

class LibraryPage2 extends StatefulWidget {
  const LibraryPage2({super.key});

  @override
  State<LibraryPage2> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage2> {
  bool _newestFirst = true; // true = descending, false = ascending

  int _compareTimestamp(dynamic a, dynamic b) {
    final aTs = a is Timestamp ? a.millisecondsSinceEpoch : 0;
    final bTs = b is Timestamp ? b.millisecondsSinceEpoch : 0;
    return _newestFirst ? bTs.compareTo(aTs) : aTs.compareTo(bTs);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.video_library_outlined,
                      size: 48,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Videos Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload a soccer video from the Upload tab\nand your analyzed matches will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Sort by created_at timestamp
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          return _compareTimestamp(aData['created_at'], bData['created_at']);
        });

        return Column(
          children: [
            // Sort bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Text(
                    '${docs.length} video${docs.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => setState(() => _newestFirst = !_newestFirst),
                    icon: Icon(
                      _newestFirst
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 16,
                    ),
                    label: Text(
                      _newestFirst ? 'Newest first' : 'Oldest first',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _AnalysisCard(data: data);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalysisCard({required this.data});

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '';
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'unknown';
    final progress = (data['progress'] ?? 0).toDouble();
    final goalCount = data['goal_count'] ?? 0;
    final goals = List<Map<String, dynamic>>.from(data['goals'] ?? []);

    final timeStr = _formatTimestamp(data['dateCreated']);
    final videoUrl = data['videoUrl'] ?? '';
    final thumbnailUrl = data['thumbnailUrl'] ?? '';
    final name = data['name'] ?? '';
    final isDone = status == 'done';

    return Card(
      color: const Color(0xFFF1F8E9),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDone && videoUrl.isNotEmpty
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoPage(name: name, videoUrl: videoUrl)),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Image.network(thumbnailUrl,width: 100,)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video name + time
                    Row(
                      children: [
                        const Icon(
                          Icons.videocam,
                          size: 20,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeStr.isNotEmpty)
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Status row
                    Row(
                      children: [
                        _statusIcon(status),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _statusLabel(status),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '$goalCount goal${goalCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: goalCount > 0
                                ? const Color(0xFF2E7D32)
                                : Colors.black38,
                          ),
                        ),
                      ],
                    ),

                    // Progress bar for processing videos
                    if (status == 'processing' || status == 'queued') ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: status == 'queued' ? null : progress / 100,
                        backgroundColor: Colors.black12,
                        color: const Color(0xFF43A047),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status == 'queued'
                            ? 'Waiting to start...'
                            : '${progress.toStringAsFixed(1)}% processed',
                        style: const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],

                    // Error message
                    if (status == 'error')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data['error'] ?? 'Unknown error',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    // Expandable goal list
                    if (isDone && goals.isNotEmpty) _GoalExpansionTile(goals: goals),

                    // Tap hint for completed analyses
                    if (isDone && videoUrl.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Watch Video',
                            style: TextStyle(color: Colors.black38, fontSize: 11),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 16, color: Colors.black38),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'done':
        return const Icon(
          Icons.check_circle,
          color: Color(0xFF66BB6A),
          size: 24,
        );
      case 'processing':
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF43A047),
          ),
        );
      case 'queued':
        return const Icon(Icons.schedule, color: Colors.amber, size: 24);
      case 'error':
        return const Icon(Icons.error, color: Colors.redAccent, size: 24);
      default:
        return const Icon(Icons.help_outline, color: Colors.black26, size: 24);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'Analysis Complete';
      case 'processing':
        return 'Processing...';
      case 'queued':
        return 'Queued';
      case 'error':
        return 'Error';
      default:
        return 'Unknown';
    }
  }
}

// ---------------------------------------------------------------------------
// Expandable goal list
// ---------------------------------------------------------------------------
class _GoalExpansionTile extends StatelessWidget {
  final List<Map<String, dynamic>> goals;

  const _GoalExpansionTile({required this.goals});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        title: Text(
          '${goals.length} goal${goals.length == 1 ? '' : 's'} detected',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        leading: const Icon(
          Icons.sports_soccer_rounded,
          color: Color(0xFF43A047),
          size: 20,
        ),
        children: goals.map((goal) => _goalRow(goal)).toList(),
      ),
    );
  }

  Widget _goalRow(Map<String, dynamic> goal) {
    final zone = goal['zone'] ?? 'Unknown';
    final start = (goal['clip_start_sec'] ?? 0).toDouble();
    final end = (goal['clip_end_sec'] ?? 0).toDouble();
    final timeSec = (goal['time_sec'] ?? 0).toDouble();
    final goalNum = goal['goal_number'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF43A047),
            child: Text(
              '$goalNum',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone, style: const TextStyle(fontSize: 14)),
                Text(
                  'at ${timeSec.toStringAsFixed(1)}s',
                  style: const TextStyle(color: Colors.black38, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${start.toStringAsFixed(1)}s – ${end.toStringAsFixed(1)}s',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
