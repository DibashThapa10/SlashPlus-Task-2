import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_2/features/video_screen/bloc/video_bloc.dart';

class RestartControls extends StatelessWidget {
  final bool isPlaying;
  final bool isComplete;

  const RestartControls({super.key,required this.isPlaying, required this.isComplete});
 

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