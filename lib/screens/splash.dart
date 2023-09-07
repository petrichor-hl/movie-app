import 'package:flutter/material.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/data/topics_data.dart';
import 'package:movie_app/main.dart';

import 'package:movie_app/onboarding/onboarding.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _redirect() async {
    await fetchTopicsData();
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/bottom_nav');
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
