import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_todo/features/todo/domain/entities/attachment_entity.dart';

class AttachmentViewer extends StatefulWidget {
  final AttachmentEntity attachment;

  const AttachmentViewer({super.key, required this.attachment});

  @override
  State<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends State<AttachmentViewer> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.attachment.type == 'video') {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.attachment.fileUrl))
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.attachment.fileName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: widget.attachment.type == 'image'
            ? InteractiveViewer(
                child: Image.network(
                  widget.attachment.fileUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_videoController!),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.blue,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    Center(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
