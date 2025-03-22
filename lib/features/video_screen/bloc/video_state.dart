part of 'video_bloc.dart';

enum PlaybackState { playing, paused }

class VideoState {}

class VideoSequenceInitial extends VideoState {}

class VideoSequenceReady extends VideoState {
  final List<VideoDataModel> videos;
  final int currentVideoIndex;
  final PlaybackState playbackState;
  final bool isSequenceComplete;
 
  final bool isFinalPhase; // Flag to track final playback phase (after third video)

  VideoSequenceReady({
    required this.videos,
    required this.currentVideoIndex,
    required this.playbackState,
    this.isSequenceComplete = false,
   
      this.isFinalPhase = false,
  });

  VideoSequenceReady copyWith({
    List<VideoDataModel>? videos,
    int? currentVideoIndex,
    PlaybackState? playbackState,
    bool? isSequenceComplete,
   
      bool? isFinalPhase,
  }) {
    return VideoSequenceReady(
      videos: videos ?? this.videos,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
      playbackState: playbackState ?? this.playbackState,
      isSequenceComplete: isSequenceComplete ?? this.isSequenceComplete,
    
      isFinalPhase: isFinalPhase ?? this.isFinalPhase,
    );
  }
}
// Error state for video loading failures
class VideoSequenceError extends VideoState {
  final String message;

  VideoSequenceError({required this.message});
}
