import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessSlider extends StatefulWidget {
  const BrightnessSlider(
    this.overlayVisible,
    this.startCountdownToDismissControls,
    this.cancelTimer, {
    super.key,
  });

  final bool overlayVisible;
  final void Function() startCountdownToDismissControls;
  final void Function() cancelTimer;

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider> {
  double brightness = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedOpacity(
        opacity: widget.overlayVisible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 130,
              child: RotatedBox(
                quarterTurns: -1,
                child: Slider(
                  value: brightness,
                  onChangeStart: (_) => widget.cancelTimer(),
                  onChanged: (value) {
                    try {
                      ScreenBrightness().setScreenBrightness(brightness);
                    } catch (e) {
                      //
                    }
                    setState(() {
                      brightness = value;
                    });
                  },
                  onChangeEnd: (_) => widget.startCountdownToDismissControls,
                ),
              ),
            ),
            const Icon(
              Icons.sunny,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
