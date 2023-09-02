import 'package:flutter/material.dart';

class VideoBottomUtils extends StatelessWidget {
  const VideoBottomUtils(
    this.overlayVisible, {
    super.key,
  });

  final bool overlayVisible;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: overlayVisible ? const Offset(0, 0) : const Offset(0, 1.2),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.speed_rounded),
              label: const Text('Tốc độ'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () {},
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
