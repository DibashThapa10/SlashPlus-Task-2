import 'package:video_player/video_player.dart';

class VideoDataModel {
  final String id;
  final String title;
  final VideoPlayerController controller;
  final Duration duration;
  final Duration position;

  VideoDataModel({
    required this.id,
    required this.title,
    required this.controller,
    required this.duration,
    this.position = Duration.zero,
  });

  VideoDataModel copyWith({Duration? position}) {
    return VideoDataModel(
      id: id,
      title: title,
      controller: controller,
      duration: duration,
      position: position ?? this.position,
    );
  }
}