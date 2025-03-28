import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_2/features/video_screen/model/video_model.dart';
import 'package:task_2/features/video_screen/service/video_service.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoService repository;
  Timer? _pauseTimer;

  final List<VoidCallback> _positionListeners = [];
  Timer? _completionCheckTimer;

  VideoBloc(this.repository) : super(VideoSequenceInitial()) {
    on<InitializeVideos>(_onInitialize);
    on<PlayVideo>(_onPlay);
    on<PauseVideo>(_onPause);
    on<VideoCompleted>(_onVideoCompleted);
    on<UpdateProgress>(_onUpdateProgress);
    on<AppPaused>(_onAppPaused);
    on<AppResumed>(_onAppResumed);
  }

  // Initialize videos and setup position listeners
  Future<void> _onInitialize(
    InitializeVideos event,
    Emitter<VideoState> emit,
  ) async {
    try {
      final videos = await repository.loadVideos();

      // Initialize position listeners
      for (var video in videos) {
        listener() {
          if (video.controller.value.isPlaying) {
            add(UpdateProgress(video.id, video.controller.value.position));
          }
        }

        // Store the listener reference
        _positionListeners.add(listener);

        // Add the listener to the video controller
        video.controller.addListener(listener);
      }

      emit(
        VideoSequenceReady(
          videos: videos,
          currentVideoIndex: 0,
          playbackState: PlaybackState.paused,
        ),
      );
    } catch (e) {
      emit(VideoSequenceError(message: 'Error loading videos: $e'));
    }
  }

  // Handle video playback start/resume
  Future<void> _onPlay(PlayVideo event, Emitter<VideoState> emit) async {
    if (state is! VideoSequenceReady) return;
    final currentState = state as VideoSequenceReady;

   // Cancel existing timers
    _pauseTimer?.cancel();

    // Only set timers in initial phase
    if (!currentState.isFinalPhase) {
      _pauseTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final position =
            currentState
                .videos[currentState.currentVideoIndex]
                .controller
                .value
                .position
                .inSeconds;

         // Check pause conditions based on current video
        if ((currentState.currentVideoIndex == 0 && position >= 15) ||
            (currentState.currentVideoIndex == 1 && position >= 20)) {
          timer.cancel();
          add(PauseVideo());
        }
      });

     
    }

    // Start video playback

    await currentState.videos[currentState.currentVideoIndex].controller.play();

    // Start completion checker
    _completionCheckTimer?.cancel();
    _completionCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final controller =
          currentState.videos[currentState.currentVideoIndex].controller;
      if (controller.value.position >= controller.value.duration) {
        add(VideoCompleted());
      }
    });

    emit(currentState.copyWith(playbackState: PlaybackState.playing));
  }

  // Handle video pause events
  Future<void> _onPause(PauseVideo event, Emitter<VideoState> emit) async {
    if (state is! VideoSequenceReady) return;
    final currentState = state as VideoSequenceReady;
    final currentVideo = currentState.videos[currentState.currentVideoIndex];

    // Capture exact pause position
    final pausedPosition = currentVideo.controller.value.position;
    add(UpdateProgress(currentVideo.id, pausedPosition));

    await currentVideo.controller.pause();
    emit(currentState.copyWith(playbackState: PlaybackState.paused));

    _handleSequenceAfterPause(currentState, emit);
  }

  // Determine next video after pause
  void _handleSequenceAfterPause(
    VideoSequenceReady currentState,
    Emitter<VideoState> emit,
  ) {
    int nextIndex = currentState.currentVideoIndex;
    switch (currentState.currentVideoIndex) {
      case 0:
        nextIndex = 1;
        break;
      case 1:
        nextIndex = 2;
        break;
      case 2:
        // Third video completes normally, handled by VideoCompleted event
        return;
    }

    emit(
      currentState.copyWith(
        currentVideoIndex: nextIndex,
        playbackState: PlaybackState.playing,
      ),
    );

    add(PlayVideo());
  }

  // Handle video completion events
  Future<void> _onVideoCompleted(
    VideoCompleted event,
    Emitter<VideoState> emit,
  ) async {
    if (state is! VideoSequenceReady) return;
    final currentState = state as VideoSequenceReady;
    final currentIndex = currentState.currentVideoIndex;

    if (currentIndex == 2) {
      // Restart second video (full playback)
      await currentState.videos[1].controller.seekTo(Duration.zero);
      emit(
        currentState.copyWith(
          currentVideoIndex: 1,
          playbackState: PlaybackState.playing,
          isFinalPhase: true, // New flag to track final sequence phase
        ),
      );
      add(PlayVideo());
    } else if (currentIndex == 1) {
      if (currentState.isFinalPhase) {
        // Resume first video from 15s (full playback)
        await currentState.videos[0].controller.seekTo(
          const Duration(seconds: 15),
        );
        emit(
          currentState.copyWith(
            currentVideoIndex: 0,
            playbackState: PlaybackState.playing,
            isFinalPhase: true,
          ),
        );
        add(PlayVideo());
      } else {
        // First time playing second video
        emit(
          currentState.copyWith(
            currentVideoIndex: 2,
            playbackState: PlaybackState.playing,
          ),
        );
        add(PlayVideo());
      }
    } else if (currentIndex == 0) {
      // First video completed in final phase
      await currentState.videos[0].controller.pause();
      await currentState.videos[0].controller.seekTo(Duration.zero);
      emit(
        currentState.copyWith(
          playbackState: PlaybackState.paused,
          isSequenceComplete: true,
          isFinalPhase: false,
          currentVideoIndex: 0,
        ),
      );
    }
  }

  // Update video progress in state
  void _onUpdateProgress(UpdateProgress event, Emitter<VideoState> emit) {
    if (state is! VideoSequenceReady) return;
    final currentState = state as VideoSequenceReady;

    final updatedVideos =
        currentState.videos.map((video) {
          if (video.id == event.videoId) {
            return video.copyWith(position: event.position);
          }
          return video;
        }).toList();

    emit(currentState.copyWith(videos: updatedVideos));
  }

  // Handle app backgrounding
  Future<void> _onAppPaused(AppPaused event, Emitter<VideoState> emit) async {
    if (state is! VideoSequenceReady) return;
    final currentState = state as VideoSequenceReady;

    if (currentState.playbackState == PlaybackState.playing) {
      await currentState.videos[currentState.currentVideoIndex].controller
          .pause();
      emit(currentState.copyWith(playbackState: PlaybackState.paused));
    }
  }

  // Handle app foregrounding
  Future<void> _onAppResumed(AppResumed event, Emitter<VideoState> emit) async {
    if (state is! VideoSequenceReady) return;
    final currentState = state as VideoSequenceReady;

    if (currentState.playbackState == PlaybackState.playing) {
      await currentState.videos[currentState.currentVideoIndex].controller
          .play();
    }
  }

  @override
  Future<void> close() {
    _completionCheckTimer?.cancel();
    _pauseTimer?.cancel();
    for (final listener in _positionListeners) {
      listener();
    }

    return super.close();
  }
}
