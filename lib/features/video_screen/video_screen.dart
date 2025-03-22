import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_2/features/video_screen/bloc/video_bloc.dart';

import 'package:task_2/features/video_screen/widgets/restart_controls.dart';
import 'package:task_2/features/video_screen/widgets/timers_display.dart';
import 'package:task_2/features/video_screen/widgets/video_player_controls.dart';
import 'package:task_2/features/video_screen/widgets/video_progress_list.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize video loading on screen startup
    context.read<VideoBloc>().add(InitializeVideos());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle app background/foreground state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<VideoBloc>().add(AppPaused());
    } else if (state == AppLifecycleState.resumed) {
      context.read<VideoBloc>().add(AppResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player'), centerTitle: true),
      body: BlocConsumer<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoSequenceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is VideoSequenceReady) {
            return _buildVideoInterface(state);
          } else if (state is VideoSequenceError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  //main video interface layout
  Widget _buildVideoInterface(VideoSequenceReady state) {
    final currentVideo = state.videos[state.currentVideoIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // Video title
          Text(currentVideo.title, style: const TextStyle(fontSize: 18)),
          // Video player with controls overlay
          Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayerControls(currentVideo: currentVideo),
              if (state.isSequenceComplete ||
                  state.playbackState == PlaybackState.paused)
                RestartControls(
                  isPlaying: state.playbackState == PlaybackState.playing,
                  isComplete: state.isSequenceComplete,
                ),
            ],
          ),
          // Duration timers (current-total)
          TimersDisplay(video: currentVideo),
          // Progress list for all videos
          Expanded(
            child: VideoProgressList(
              videos: state.videos,
              currentIndex: state.currentVideoIndex,
            ),
          ),
        ],
      ),
    );
  }
}
