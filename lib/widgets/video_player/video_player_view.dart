import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/widgets/video_player/brightness_slider.dart';
import 'package:movie_app/widgets/video_player/control_buttons.dart';
import 'package:movie_app/widgets/video_player/video_bottom_utils.dart';

import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';

import 'package:movie_app/widgets/video_player/slider_video.dart';

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

  late Timer _timer = Timer(const Duration(seconds: 0), () {});

  void _toggleOverlay() {
    _timer.cancel();

    setState(() {
      _overlayVisible = !_overlayVisible;
    });

    if (_overlayVisible) {
      // Hide the overlay after a delay
      _startCountdownToDismissControls();
    }
  }

  void _startCountdownToDismissControls() {
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _overlayVisible = false;
      });
    });
  }

  void _onVideoPlayerPositionChanged() {
    context.read<VideoSliderCubit>().setProgress(
        _videoPlayerController.value.position.inMilliseconds /
            _videoPlayerController.value.duration.inMilliseconds);
  }

  @override
  void initState() {
    super.initState();

    // prevents the screen from turning off automatically.
    Wakelock.enable();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.episodeUrl))
          ..initialize().then((value) {
            _videoPlayerController.addListener(_onVideoPlayerPositionChanged);

            _videoPlayerController.addListener(() {
              _videoPlayerController.value.isPlaying
                  ? context.read<VideoPlayControlCubit>().play()
                  : context.read<VideoPlayControlCubit>().pause();
            });

            setState(() {});
          })
          ..play();
  }

  @override
  void dispose() {
    Wakelock.disable();

    // Nếu gọi lệnh ở "setPreferredOrientations" ở đây thay vì ở arrow_back button thì
    // hướng màn hình sẽ không chuyển thành portrait ngay lập tức.
    // Mà phải về màn hình trước đó mới chuyển

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _videoPlayerController.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.isInitialized
                    ? _videoPlayerController.value.aspectRatio
                    : 16 / 9,
                child: _videoPlayerController.value.isInitialized
                    ? VideoPlayer(_videoPlayerController)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            AnimatedOpacity(
              opacity: _overlayVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                height: double.infinity,
                child: IgnorePointer(
                  ignoring: !_overlayVisible,
                  child: ControlButtons(
                    _videoPlayerController,
                    _startCountdownToDismissControls,
                    () => _timer.cancel(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: Platform.isAndroid ? 20 : 0,
              right: Platform.isAndroid ? 20 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset:
                    _overlayVisible ? const Offset(0, 0) : const Offset(0, -1),
                curve: Curves.easeInOut,
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Platform.isIOS
                              ? Icons.arrow_back_ios_rounded
                              : Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        width: 48,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: Platform.isAndroid ? 20 : 0,
              right: Platform.isAndroid ? 20 : 0,
              child: Column(
                children: [
                  SliderVideo(
                    _overlayVisible,
                    _videoPlayerController,
                    _startCountdownToDismissControls,
                    () => _timer.cancel(),
                    () => _videoPlayerController
                        .removeListener(_onVideoPlayerPositionChanged),
                    () => _videoPlayerController
                        .addListener(_onVideoPlayerPositionChanged),
                  ),
                  VideoBottomUtils(_overlayVisible),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: BrightnessSlider(
                _overlayVisible,
                _startCountdownToDismissControls,
                () => _timer.cancel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
