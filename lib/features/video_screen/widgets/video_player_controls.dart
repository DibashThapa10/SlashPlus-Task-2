import 'package:flutter/material.dart';
import 'package:task_2/features/video_screen/model/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControls extends StatelessWidget {
  final VideoDataModel currentVideo;

  const VideoPlayerControls({super.key,required this.currentVideo});

 

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(currentVideo.controller),

            VideoProgressIndicator(
              currentVideo.controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: const Color.fromARGB(255, 215, 206, 206),
                backgroundColor: const Color.fromARGB(255, 111, 111, 111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}