import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/data/poster_data.dart';
import 'package:movie_app/main.dart';

import 'package:movie_app/onboarding/onboarding.dart';
import 'package:movie_app/screens/bottom_nav.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _redirect() async {
    await fetchPosterData();
    await Future.delayed(2.seconds);

    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const BottomNavScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const OnboardingScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.primary,
        highlightColor: Colors.amber,
        child: Image.asset(
          Assets.netflixLogo,
          width: 240,
        ),
      ),
    );
  }
}
