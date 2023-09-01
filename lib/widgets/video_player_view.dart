import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _videoPlayerController = VideoPlayerController.asset(widget.episodeUrl)
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
    // Nếu gọi lệnh ở "setPreferredOrientations" ở đây thay vì ở arrow_back button thì
    // hướng màn hình sẽ không chuyển thành portrait ngay lập tức.
    // Mà phải về màn hình trước đó mới chuyển

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

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
                  child: _ControlButtons(
                    _videoPlayerController,
                    _startCountdownToDismissControls,
                    () => _timer.cancel(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset:
                    _overlayVisible ? const Offset(0, 0) : const Offset(0, -1),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
              left: 0,
              right: 0,
              child: BlocBuilder<VideoSliderCubit, double>(
                builder: (ctx, progress) {
                  return _SliderVideo(
                    progress,
                    _overlayVisible,
                    _videoPlayerController,
                    _startCountdownToDismissControls,
                    () => _timer.cancel(),
                    () => _videoPlayerController
                        .removeListener(_onVideoPlayerPositionChanged),
                    () => _videoPlayerController
                        .addListener(_onVideoPlayerPositionChanged),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButtons extends StatelessWidget {
  const _ControlButtons(
    this.videoPlayerController,
    this.startCountdownToDismissControls,
    this.cancelTimer,
  );

  final VideoPlayerController videoPlayerController;
  final void Function() cancelTimer;
  final void Function() startCountdownToDismissControls;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            videoPlayerController.seekTo(videoPlayerController.value.position -
                const Duration(seconds: 10));
          },
          icon: const Icon(
            Icons.replay_10_rounded,
            size: 60,
          ),
          style: IconButton.styleFrom(foregroundColor: Colors.white),
        ),
        BlocBuilder<VideoPlayControlCubit, VideoState>(
          builder: (context, videoState) {
            return IconButton(
              onPressed: () {
                if (videoPlayerController.value.isPlaying) {
                  videoPlayerController.pause();
                } else {
                  videoPlayerController.play();
                }
                cancelTimer();
                startCountdownToDismissControls();
              },
              icon: Icon(
                videoState == VideoState.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 60,
              ),
              style: IconButton.styleFrom(foregroundColor: Colors.white),
            );
          },
        ),
        IconButton(
          onPressed: () {
            videoPlayerController.seekTo(
              videoPlayerController.value.position +
                  const Duration(seconds: 10),
            );
          },
          icon: const Icon(
            Icons.forward_10_rounded,
            size: 60,
          ),
          style: IconButton.styleFrom(foregroundColor: Colors.white),
        ),
      ],
    );
  }
}

String _convertFromDuration(Duration duration) {
  int mins = duration.inMinutes;
  int secs = duration.inSeconds % 60;

  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String _convertFromSeconds(int initalSeconds) {
  int mins = (initalSeconds ~/ 60);
  int secs = (initalSeconds % 60);
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

class _SliderVideo extends StatelessWidget {
  const _SliderVideo(
    this.progressSlider,
    this.overlayVisible,
    this.videoPlayerController,
    this.startCountdownToDismissControls,
    this.cancelTimer,
    this.removeProgressListener,
    this.addProgressListener,
  );

  final double progressSlider;
  final bool overlayVisible;
  final VideoPlayerController videoPlayerController;
  final void Function() cancelTimer;
  final void Function() startCountdownToDismissControls;

  final void Function() removeProgressListener;
  final void Function() addProgressListener;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: overlayVisible ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: IgnorePointer(
            ignoring: !overlayVisible,
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: progressSlider,
                    label: _convertFromSeconds(
                      (progressSlider *
                              videoPlayerController.value.duration.inSeconds)
                          .toInt(),
                    ),
                    onChanged: (value) {
                      context.read<VideoSliderCubit>().setProgress(value);
                    },
                    onChangeStart: (value) async {
                      await videoPlayerController.pause();
                      removeProgressListener();
                      cancelTimer();
                    },
                    onChangeEnd: (value) async {
                      await videoPlayerController.seekTo(
                        Duration(
                          milliseconds: (value *
                                  videoPlayerController
                                      .value.duration.inMilliseconds)
                              .toInt(),
                        ),
                      );
                      addProgressListener();
                      videoPlayerController.play();
                      startCountdownToDismissControls();
                    },
                  ),
                ),
                Text(
                  _convertFromDuration(videoPlayerController.value.duration -
                      videoPlayerController.value.position),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )),
    );
  }
}
