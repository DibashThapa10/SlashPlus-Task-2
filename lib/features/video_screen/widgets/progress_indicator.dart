import 'package:flutter/material.dart';
import 'package:task_2/features/video_screen/model/video_model.dart';

class ProgressIndicatorVideo extends StatelessWidget {
  final VideoDataModel video;
  final bool isActive;

  const ProgressIndicatorVideo({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(video.title),
          LinearProgressIndicator(
            value: video.position.inSeconds / video.duration.inSeconds,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          Text(
            '${video.position.inSeconds}/${video.duration.inSeconds} seconds',
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}