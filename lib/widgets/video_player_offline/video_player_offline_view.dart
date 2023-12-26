import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/models/offfline_season.dart';
import 'package:movie_app/models/offline_episode.dart';
import 'package:movie_app/widgets/video_player/brightness_slider.dart';
import 'package:movie_app/widgets/video_player/control_buttons.dart';
import 'package:movie_app/widgets/video_player/slider_video.dart';
import 'package:movie_app/widgets/video_player_offline/video_offline_bottom_utils.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoPlayerOfflineView extends StatefulWidget {
  const VideoPlayerOfflineView({
    super.key,
    required this.filmId,
    required this.seasons,
    required this.firstEpisodeToPlay,
    required this.firstSeasonIndex,
  });

  final String filmId;
  final List<OfflineSeason> seasons;
  final OfflineEpisode firstEpisodeToPlay;
  final int firstSeasonIndex;

  @override
  State<VideoPlayerOfflineView> createState() => _VideoPlayerOfflineViewState();
}

class _VideoPlayerOfflineViewState extends State<VideoPlayerOfflineView> {
  late VideoPlayerController _videoPlayerController;

  bool _isLockControls = false;

  bool _controlsOverlayVisible = false;
  bool _lockOverlayVisible = true;
  // True, because when lock controls, Lock IconButton will raise

  late Timer _controlsTimer = Timer(Duration.zero, () {});
  late Timer _lockTimer = Timer(Duration.zero, () {});

  late bool isMovie;

  late int _currentSeasonIndex = widget.firstSeasonIndex;
  late OfflineEpisode _currentEpisode;

  void setLock(bool value) {
    _isLockControls = value;

    if (_isLockControls) {
      _controlsOverlayVisible = false;
      _lockOverlayVisible = true;
      _startCountdownToDismissLockButton();
    } else {
      _controlsOverlayVisible = true;
      _startCountdownToDismissControls();
    }

    setState(() {});
  }

  void _toggleControlsOverlay() {
    _controlsTimer.cancel();

    setState(() {
      _controlsOverlayVisible = !_controlsOverlayVisible;
    });

    if (_controlsOverlayVisible) {
      // Hide the overlay after a delay
      _startCountdownToDismissControls();
    }
  }

  void _toggleLockOverlay() {
    _lockTimer.cancel();

    setState(() {
      _lockOverlayVisible = !_lockOverlayVisible;
    });

    if (_lockOverlayVisible) {
      // Hide the overlay after a delay
      _startCountdownToDismissLockButton();
    }
  }

  void _startCountdownToDismissControls() {
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      setState(() {
        _controlsOverlayVisible = false;
      });
    });
  }

  void _startCountdownToDismissLockButton() {
    _lockTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _lockOverlayVisible = false;
      });
    });
  }

  void _onVideoPlayerPositionChanged() {
    context.read<VideoSliderCubit>().setProgress(
        _videoPlayerController.value.position.inMilliseconds /
            _videoPlayerController.value.duration.inMilliseconds);
  }

  void _onVideoPlayerStatusChanged() {
    _videoPlayerController.value.isPlaying
        ? context.read<VideoPlayControlCubit>().play()
        : context.read<VideoPlayControlCubit>().pause();
  }

  void setBrightness(double brightness) {
    try {
      ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      //
    }
  }

  void resetBrightness() {
    try {
      ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      //
    }
  }

  void setVideoController(OfflineEpisode episode) {
    _controlsTimer.cancel();
    _currentEpisode = episode;

    setState(() {
      _controlsOverlayVisible = false;
    });

    // print('LOADING VIDEO FROM LOCAL');
    String link = isMovie
        ? '${appDir.path}/episode/${episode.episodeId}.mp4'
        : '${appDir.path}/episode/${widget.filmId}/${episode.episodeId}.mp4';

    _videoPlayerController = VideoPlayerController.file(
      File(link),
    );

    _videoPlayerController.initialize().then((value) {
      _videoPlayerController.addListener(_onVideoPlayerPositionChanged);
      _videoPlayerController.addListener(_onVideoPlayerStatusChanged);
      setState(() {
        _controlsOverlayVisible = true;
      });
      _videoPlayerController.play().then((_) => _startCountdownToDismissControls());
    });
  }

  @override
  void initState() {
    super.initState();

    // prevents the screen from turning off automatically.
    Wakelock.enable();

    setBrightness(1);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    isMovie = widget.seasons[0].name == '';
    setVideoController(widget.firstEpisodeToPlay);
  }

  @override
  void dispose() {
    Wakelock.disable();
    resetBrightness();

    // Nếu gọi lệnh ở "setPreferredOrientations" ở đây thay vì ở arrow_back button thì
    // hướng màn hình sẽ không chuyển thành portrait ngay lập tức.
    // Mà phải về màn hình trước đó mới chuyển
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _videoPlayerController.dispose();
    _controlsTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _videoPlayerController.value.isInitialized
            ? _isLockControls
                ? _toggleLockOverlay
                : _toggleControlsOverlay
            : null,
        child: Stack(
          children: [
            /* Video */
            Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.isInitialized
                    ? _videoPlayerController.value.aspectRatio
                    : 16 / 9,
                child: _videoPlayerController.value.isInitialized
                    ? VideoPlayer(_videoPlayerController)
                    : const Center(
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                        ),
                      ),
              ),
            ),
            /* Controls Button */
            AnimatedOpacity(
              opacity: _controlsOverlayVisible ? 1.0 : 0.0,
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
                  ignoring: !_controlsOverlayVisible,
                  child: ControlButtons(
                    _videoPlayerController,
                    _startCountdownToDismissControls,
                    () => _controlsTimer.cancel(),
                  ),
                ),
              ),
            ),
            // Header
            Positioned(
              top: 0,
              left: Platform.isAndroid ? 20 : 0,
              right: Platform.isAndroid ? 20 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset:
                    _controlsOverlayVisible ? const Offset(0, 0) : const Offset(0, -1),
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
                          _currentEpisode.title,
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
            // Bottom Utils
            Positioned(
              bottom: 0,
              left: Platform.isAndroid ? 20 : 0,
              right: Platform.isAndroid ? 20 : 0,
              child: Column(
                children: [
                  SliderVideo(
                    _controlsOverlayVisible,
                    _videoPlayerController,
                    _startCountdownToDismissControls,
                    () => _controlsTimer.cancel(),
                    () => _videoPlayerController
                        .removeListener(_onVideoPlayerPositionChanged),
                    () =>
                        _videoPlayerController.addListener(_onVideoPlayerPositionChanged),
                  ),
                  VideoOfflineBottomUtils(
                    overlayVisible: _controlsOverlayVisible,
                    videoPlayerController: _videoPlayerController,
                    startCountdownToDismissControls: _startCountdownToDismissControls,
                    cancelTimer: () => _controlsTimer.cancel(),
                    lockControls: setLock,
                    /* 
                    Truyền filmId vào để DownloadedEpisodeUISecond có thể truy xuất được 
                    đường link dẫn đến nơi lưu episode và stillPath
                    */
                    filmId: widget.filmId,
                    seasons: widget.seasons,
                    seasonIndex: _currentSeasonIndex,
                    currentEpisodeId: _currentEpisode.episodeId,
                    moveToEdpisode: (episode, seasonIndex) {
                      /*
                      Remove Listener để không xảy ra lỗi
                      VD: 
                      _onVideoPlayerPositionChanged sẽ kích hoạt cả khi _videoPlayerController bị destruct
                      Khi đó, 
                      _videoPlayerController.value.duration.inMilliseconds = 0; => Lỗi
                      */
                      _videoPlayerController
                          .removeListener(_onVideoPlayerPositionChanged);
                      _videoPlayerController.removeListener(_onVideoPlayerStatusChanged);
                      //
                      _videoPlayerController.dispose();
                      //
                      _currentSeasonIndex = seasonIndex;
                      setVideoController(episode);
                    },
                  ),
                ],
              ),
            ),
            // Brightness Screen Slider
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: BrightnessSlider(
                _controlsOverlayVisible,
                _startCountdownToDismissControls,
                () => _controlsTimer.cancel(),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.9),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: _isLockControls && _lockOverlayVisible
                    ? const Offset(0, 0)
                    : const Offset(0, 1.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setLock(false);
                      },
                      icon: const Icon(
                        Icons.lock_outline,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      'Màn hình đã khoá',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
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
