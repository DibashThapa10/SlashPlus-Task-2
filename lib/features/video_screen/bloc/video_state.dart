part of 'video_bloc.dart';

enum PlaybackState { playing, paused }

class VideoState {}

class VideoSequenceInitial extends VideoState {}

class VideoSequenceReady extends VideoState {
  final List<VideoDataModel> videos;
  final int currentVideoIndex;
  final PlaybackState playbackState;
  final bool isSequenceComplete;
  final bool isSecondPlay;

  VideoSequenceReady({
    required this.videos,
    required this.currentVideoIndex,
    required this.playbackState,
    this.isSequenceComplete = false,
    this.isSecondPlay = false,
  });

  VideoSequenceReady copyWith({
    List<VideoDataModel>? videos,
    int? currentVideoIndex,
    PlaybackState? playbackState,
    bool? isSequenceComplete,
    bool? isSecondPlay,
  }) {
    return VideoSequenceReady(
      videos: videos ?? this.videos,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
      playbackState: playbackState ?? this.playbackState,
      isSequenceComplete: isSequenceComplete ?? this.isSequenceComplete,
      isSecondPlay: isSecondPlay ?? this.isSecondPlay,
    );
  }
}

class VideoSequenceError extends VideoState {
  final String message;

  VideoSequenceError({required this.message});
}
