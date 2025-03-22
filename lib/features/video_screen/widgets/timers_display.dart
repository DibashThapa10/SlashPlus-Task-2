import 'package:flutter/material.dart';
import 'package:task_2/features/video_screen/model/video_model.dart';

class TimersDisplay extends StatelessWidget {
  final VideoDataModel video;

  const TimersDisplay({super.key,required this.video});

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDuration(video.controller.value.position),
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            _formatDuration(video.duration),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
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