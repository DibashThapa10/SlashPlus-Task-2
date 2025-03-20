import 'package:task_2/features/video_screen/model/video_model.dart';
import 'package:video_player/video_player.dart';

// class VideoService {
//   Future<List<VideoDataModel>> loadVideos() async {
    
//     return [
//       VideoDataModel(
//         id: 'video1',
//         title: 'First Video',
//         controller: VideoPlayerController.asset('assets/videos/video1.mp4')
//           ..initialize(),
//         duration: const Duration(seconds: 60),
//       ),
//       VideoDataModel(
//         id: 'video2',
//         title: 'Second Video',
//         controller: VideoPlayerController.asset('assets/videos/video2.mp4')
//           ..initialize(),
//         duration: const Duration(seconds: 45),
//       ),
//       VideoDataModel(
//         id: 'video3',
//         title: 'Third Video',
//         controller: VideoPlayerController.asset('assets/videos/video3.mp4')
//           ..initialize(),
//         duration: const Duration(seconds: 30),
//       ),
//     ];
//   }
// }
class VideoService {
  Future<List<VideoDataModel>> loadVideos() async {
    final videos = [
      await _initializeVideo('assets/videos/video1.mp4', 'First Video'),
      await _initializeVideo('assets/videos/video2.mp4', 'Second Video'),
      await _initializeVideo('assets/videos/video3.mp4', 'Third Video'),
    ];
    return videos;
  }

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