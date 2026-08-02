import 'dart:io';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../widgets/video_player_widget.dart';


class UploadPage2 extends StatefulWidget {
  const UploadPage2({super.key});

  @override
  State<UploadPage2> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage2> {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedVideo;
  VideoPlayerController? _videoController;
  bool _uploading = false;

  final nameController=TextEditingController();

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(source: source);
    if (video == null) return;

    // Dispose previous controller if any
    _videoController?.dispose();

    final controller = VideoPlayerController.file(File(video.path));
    await controller.initialize();

    setState(() {
      _selectedVideo = video;
      _videoController = controller;
    });
  }

  void _cancelPreview() {
    _videoController?.dispose();
    setState(() {
      _selectedVideo = null;
      _videoController = null;
    });
  }

  String _uploadStatus = '';

  Future<void> _uploadVideo(String name) async {
    if (_selectedVideo == null) return;

    setState(() {
      _uploading = true;
      _uploadStatus = 'Uploading video to server...';
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Send video to Flask server (server handles Firebase Storage upload)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/analyze'),
      );
      request.fields['user_id'] = userId;
      request.fields['name']= name;
      request.files.add(
        await http.MultipartFile.fromPath('video', _selectedVideo!.path),
      );

      final response = await request.send();
      final body = json.decode(await response.stream.bytesToString());

      if (!mounted) return;

      if (response.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing started! Check Library for progress.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _cancelPreview();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${body['error'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_uploading) {
      return _buildUploading();
    }
    if (_selectedVideo != null && _videoController != null) {
      return _buildPreview(_selectedVideo!);
    }
    return _buildPicker();
  }

  // -- Uploading state ----------------------------------------------------
  Widget _buildUploading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Color(0xFF43A047),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _uploadStatus.isNotEmpty ? _uploadStatus : 'Uploading video...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a moment',
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }

  // -- Video preview state ------------------------------------------------
  Widget _buildPreview(XFile pickedVideo) {
    return Column(
      children: [
        AnalysisVideoPlayer(localFile: pickedVideo,),
        Container(
            width: 200,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  )
              ),
            )
        ),


        // Action buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cancelPreview,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(

                  child: FilledButton.icon(
                    onPressed:()=> _uploadVideo(nameController.text),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -- Picker state -------------------------------------------------------
  Widget _buildPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_soccer,
              size: 72,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Analyze Soccer Match',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Record or select a video and our AI will\ndetect every goal automatically',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black45, height: 1.5),
          ),
          const SizedBox(height: 44),
          _OptionCard(
            icon: Icons.videocam_rounded,
            title: 'Record Video',
            subtitle: 'Use your camera to capture a match',
            onTap: () => _pickVideo(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          _OptionCard(
            icon: Icons.photo_library_rounded,
            title: 'Choose from Gallery',
            subtitle: 'Select an existing video from your device',
            onTap: () => _pickVideo(ImageSource.gallery),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Color(0xFFF9A825), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For best results, position the camera behind the goal.',
                    style: TextStyle(fontSize: 13, color: Colors.brown[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// -------------------------------------------------------------------------
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
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
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
