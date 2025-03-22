import 'package:flutter/material.dart';
import 'package:task_2/features/video_screen/model/video_model.dart';

class VideoProgressList extends StatelessWidget {
  final List<VideoDataModel> videos;
  final int currentIndex;

  const VideoProgressList({
    super.key,
    required this.videos,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final bool isActive = index == currentIndex;
        final double progress =
            video.position.inSeconds / video.duration.inSeconds;
        return Card(
          elevation: 2,
          color: isActive ? Colors.blue[50] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isActive ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatDuration(video.controller.value.position)} / ${_formatDuration(video.duration)}',
                  style: TextStyle(color: isActive ? Colors.blue : Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return [
      if (hours > 0) twoDigits(hours),
      twoDigits(minutes),
      twoDigits(seconds),
    ].join(':');
  }
}
