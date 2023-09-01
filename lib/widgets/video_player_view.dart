import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double _progressSlider = 0;

  void _toggleOverlay() {
    _timer.cancel();

    setState(() {
      _overlayVisible = !_overlayVisible;
    });

    if (_overlayVisible) {
      // Hide the overlay after a delay
      _timer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _overlayVisible = false;
        });
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
        (value) => setState(() {
          _videoPlayerController.addListener(() {
            setState(() {
              _progressSlider =
                  _videoPlayerController.value.position.inMilliseconds /
                      _videoPlayerController.value.duration.inMilliseconds;
            });
          });
        }),
      )
      ..play();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();

    // Nếu gọi lệnh ở "setPreferredOrientations" ở đây thay vì ở arrow_back button thì
    // hướng màn hình sẽ không chuyển thành portrait ngay lập tức.

    // Dành cho trường hợp không nhấn backbutton trên màn hình mà lướt về
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _timer.cancel();
    super.dispose();
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          _videoPlayerController.seekTo(
                              _videoPlayerController.value.position -
                                  const Duration(seconds: 10));
                        },
                        icon: const Icon(
                          Icons.replay_10_rounded,
                          size: 60,
                        ),
                        style:
                            IconButton.styleFrom(foregroundColor: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_videoPlayerController.value.isPlaying) {
                            _videoPlayerController.pause();
                            _timer.cancel();
                          } else {
                            _videoPlayerController.play();
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          _videoPlayerController.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 60,
                        ),
                        style:
                            IconButton.styleFrom(foregroundColor: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          _videoPlayerController.seekTo(
                              _videoPlayerController.value.position +
                                  const Duration(seconds: 10));
                        },
                        icon: const Icon(
                          Icons.forward_10_rounded,
                          size: 60,
                        ),
                        style:
                            IconButton.styleFrom(foregroundColor: Colors.white),
                      ),
                    ],
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
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset:
                    _overlayVisible ? const Offset(0, -0) : const Offset(0, 1),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _progressSlider,
                              label: _convertFromSeconds((_progressSlider *
                                      _videoPlayerController
                                          .value.duration.inSeconds)
                                  .toInt()),
                              onChanged: (value) {
                                setState(() {
                                  _progressSlider = value;
                                });
                              },
                              onChangeStart: (value) {
                                _videoPlayerController.pause();
                                _timer.cancel();
                              },
                              onChangeEnd: (value) {
                                _videoPlayerController.seekTo(
                                  Duration(
                                      milliseconds: (value *
                                              _videoPlayerController.value
                                                  .duration.inMilliseconds)
                                          .toInt()),
                                );
                                _videoPlayerController.play();
                                _timer = Timer(const Duration(seconds: 3), () {
                                  setState(() {
                                    _overlayVisible = false;
                                  });
                                });
                              },
                            ),
                          ),
                          Text(
                            _convertFromDuration(
                                _videoPlayerController.value.duration -
                                    _videoPlayerController.value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
