import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_2/features/video_screen/bloc/video_bloc.dart';
import 'package:task_2/features/video_screen/model/video_model.dart';

import 'package:video_player/video_player.dart';

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
    context.read<VideoBloc>().add(InitializeVideos());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
            // return _buildPlayerUI(state);
            final currentVideo = state.videos[state.currentVideoIndex];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        currentVideo.title,
                        style: const TextStyle(fontSize: 18),
                      ),
                      _VideoPlayerWithControls(
                        currentVideo: state.videos[state.currentVideoIndex],
                      ),
                      _TimersDisplay(
                        video: state.videos[state.currentVideoIndex],
                      ),
                    ],
                  ),

                  // if (state.isSequenceComplete ||
                  //     state.playbackState == PlaybackState.paused)
                  _RestartControls(
                    isPlaying: state.playbackState == PlaybackState.playing,
                    isComplete: state.isSequenceComplete,
                  ),
                ],
              ),
            );
          } else if (state is VideoSequenceError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _VideoPlayerWithControls extends StatelessWidget {
  final VideoDataModel currentVideo;

  const _VideoPlayerWithControls({required this.currentVideo});

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

class _TimersDisplay extends StatelessWidget {
  final VideoDataModel video;

  const _TimersDisplay({required this.video});

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

class _RestartControls extends StatelessWidget {
  final bool isPlaying;
  final bool isComplete;

  const _RestartControls({required this.isPlaying, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            isComplete
                ? ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Restart Sequence'),
                  onPressed:
                      () => context.read<VideoBloc>().add(InitializeVideos()),
                )
                : FloatingActionButton(
                  onPressed: () {
                    if (isPlaying) {
                      context.read<VideoBloc>().add(PauseVideo());
                    } else {
                      context.read<VideoBloc>().add(PlayVideo());
                    }
                  },
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                ),
      ),
    );
  }
}
