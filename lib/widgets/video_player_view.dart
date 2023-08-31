import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/assets.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.title,
    required this.episodeUrl,
    this.startAt = 0,
  });

  final String title;
  final String episodeUrl;
  final int startAt;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late final VideoPlayerController _videoPlayerController;
  bool _overlayVisible = false;

  void _toggleOverlay() {
    setState(() {
      _overlayVisible = !_overlayVisible;
    });

    if (_overlayVisible) {
      // Hide the overlay after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _overlayVisible = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _videoPlayerController = VideoPlayerController.asset(widget.episodeUrl)
      ..initialize().then(
        (value) => setState(() {}),
      )
      ..play();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();

    // Nếu gọi lệnh ở "setPreferredOrientations" ở đây thay vì ở arrow_back button thì
    // hướng màn hình sẽ không chuyển thành portrait ngay lập tức.

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _toggleOverlay,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.isInitialized
                    ? _videoPlayerController.value.aspectRatio
                    : 16 / 9,
                child: _videoPlayerController.value.isInitialized
                    ? VideoPlayer(_videoPlayerController)
                    : Image.asset(Assets.sintel, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _overlayVisible ? 1.0 : 0.0,
                duration:
                    const Duration(milliseconds: 500), // Animation duration
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                        ]);
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
