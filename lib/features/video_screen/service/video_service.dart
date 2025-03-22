import 'package:task_2/features/video_screen/model/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoService {
  // Loads and initializes all videos from assets
  Future<List<VideoDataModel>> loadVideos() async {
    final videos = [
      await _initializeVideo('assets/videos/video1.mp4', 'First Video'),
      await _initializeVideo('assets/videos/video2.mp4', 'Second Video'),
      await _initializeVideo('assets/videos/video3.mp4', 'Third Video'),
    ];
    return videos;
  }

  // Helper method to initialize a single video controller
  Future<VideoDataModel> _initializeVideo(String path, String title) async {
    final controller = VideoPlayerController.asset(path);
    await controller.initialize();
    return VideoDataModel(
      id: path,
      title: title,
      controller: controller,
      duration: controller.value.duration,
      position: Duration.zero,
    );
  }
}