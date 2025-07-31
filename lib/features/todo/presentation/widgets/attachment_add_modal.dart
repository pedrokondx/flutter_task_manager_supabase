import 'package:flutter/material.dart';

class AttachmentAddModal extends StatelessWidget {
  final Function() onTakePhoto;
  final Function() onChooseFromGallery;
  final Function() onRecordVideo;

  const AttachmentAddModal({
    super.key,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
    required this.onRecordVideo,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take Photo'),
            onTap: onTakePhoto,
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: onChooseFromGallery,
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video'),
            onTap: onRecordVideo,
          ),
        ],
      ),
    );
  }
}
