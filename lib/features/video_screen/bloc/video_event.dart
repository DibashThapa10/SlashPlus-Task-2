part of 'video_bloc.dart';

abstract class VideoEvent {}

class InitializeVideos extends VideoEvent {}

class PlayVideo extends VideoEvent {}

class PauseVideo extends VideoEvent {}

class VideoCompleted extends VideoEvent {}

class UpdateProgress extends VideoEvent {
  final String videoId;
  final Duration position;

  UpdateProgress(this.videoId, this.position);
}

class AppPaused extends VideoEvent {}

class AppResumed extends VideoEvent {}