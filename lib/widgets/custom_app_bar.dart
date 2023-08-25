import 'package:flutter/material.dart';
import 'package:movie_app/assets.dart';

class CustomAppBar extends StatelessWidget {
  final double scrollOffset;

  const CustomAppBar({
    super.key,
    this.scrollOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          Colors.black.withOpacity((scrollOffset / 350).clamp(0, 1).toDouble()),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: SafeArea(
        child: Row(
          children: [
            Image.asset(Assets.netflixLogo0),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AppBarButton('TV Shows', scrollOffset, () {}),
                  _AppBarButton('Movie', scrollOffset, () {}),
                  _AppBarButton('My List', scrollOffset, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  const _AppBarButton(this.text, this.scrollOffset, this.onTap);

  final String text;
  final double scrollOffset;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(
            1 - (scrollOffset / 350).clamp(0.25, 1).toDouble(),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
