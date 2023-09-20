import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/data/topics_data.dart';
import 'package:movie_app/main.dart';

import 'package:movie_app/onboarding/onboarding.dart';
import 'package:movie_app/screens/main/bottom_nav.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _redirect() async {
    await fetchTopicsData();
    await getDownloadedFilms();

    // print('my_list: ${context.read<MyListCubit>().state}');
    if (!mounted) {
      return;
    }
    final session = supabase.auth.currentSession;
    if (session != null) {
      context.read<MyListCubit>().setList(await fetchMyList());
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        PageTransition(
            child: const BottomNavScreen(),
            type: PageTransitionType.fade,
            duration: 800.ms,
            settings: const RouteSettings(name: '/bottom_nav')),
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
