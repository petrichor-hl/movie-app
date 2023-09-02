import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBottomUtils extends StatelessWidget {
  VideoBottomUtils(
    this.overlayVisible,
    this.videoPlayerController,
    this.startCountdownToDismissControls,
    this.cancelTimer,
    this.lockControls, {
    super.key,
  });

  final bool overlayVisible;
  final VideoPlayerController videoPlayerController;
  final void Function() cancelTimer;
  final void Function() startCountdownToDismissControls;

  final void Function(bool) lockControls;

  final speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context) {
    double currentSpeedOption = speedOptions[2];

    return SafeArea(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: overlayVisible ? const Offset(0, 0) : const Offset(0, 1.2),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () async {
                cancelTimer();
                await showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...speedOptions.map(
                              (speedOption) => RadioListTile(
                                title: Text('${speedOption}x'),
                                value: speedOption,
                                groupValue: currentSpeedOption,
                                onChanged: (value) {
                                  currentSpeedOption = value!;
                                  videoPlayerController.setPlaybackSpeed(value);
                                  Navigator.of(context).pop();
                                },
                                dense: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Huỷ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                startCountdownToDismissControls();
              },
              icon: const Icon(Icons.speed_rounded),
              label: const Text('Tốc độ'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () => lockControls(true),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Khoá'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.view_carousel_rounded),
              label: const Text('Các tập'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('Tập tiếp theo'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
