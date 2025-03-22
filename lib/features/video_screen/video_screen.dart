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
            final currentVideo = state.videos[state.currentVideoIndex];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Text(
                    currentVideo.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _VideoPlayerWithControls(
                        currentVideo: state.videos[state.currentVideoIndex],
                      ),
                      if (state.isSequenceComplete ||
                          state.playbackState == PlaybackState.paused)
                        _RestartControls(
                          isPlaying:
                              state.playbackState == PlaybackState.playing,
                          isComplete: state.isSequenceComplete,
                        ),
                    ],
                  ),
                  _TimersDisplay(video: state.videos[state.currentVideoIndex]),
                  Expanded(
                    child: _VideoProgressList(
                      videos: state.videos,
                      currentIndex: state.currentVideoIndex,
                    ),
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

class _VideoProgressList extends StatelessWidget {
  final List<VideoDataModel> videos;
  final int currentIndex;

  const _VideoProgressList({required this.videos, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _VideoProgressItem(
          video: video,
          isActive: index == currentIndex,
        );
      },
    );
  }
}

class _VideoProgressItem extends StatelessWidget {
  final VideoDataModel video;
  final bool isActive;

  const _VideoProgressItem({required this.video, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final progress = video.position.inSeconds / video.duration.inSeconds;

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
          ],
        ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  icon: const Icon(Icons.restart_alt, color: Colors.white),
                  label: const Text(
                    'Restart',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed:
                      () => context.read<VideoBloc>().add(InitializeVideos()),
                )
                : FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    if (isPlaying) {
                      context.read<VideoBloc>().add(PauseVideo());
                    } else {
                      context.read<VideoBloc>().add(PlayVideo());
                    }
                  },
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
      ),
    );
  }
}
