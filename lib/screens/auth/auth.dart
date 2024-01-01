import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/data/topics_data.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:movie_app/assets.dart';
import 'package:movie_app/main.dart';

import 'package:movie_app/screens/auth/sign_in.dart';
import 'package:movie_app/screens/auth/sign_up.dart';
import 'package:movie_app/screens/main/bottom_nav.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _pageController = PageController(initialPage: 0);

  late final StreamSubscription<AuthState> _authSubscription;

  void _redirect() async {
    await fetchTopicsData();
    await getDownloadedFilms();
    await fetchProfileData();
    if (mounted) {
      context.read<MyListCubit>().setList(profileData['my_list']);
      Navigator.of(context).pushAndRemoveUntil(
        PageTransition(
          child: const BottomNavScreen(),
          type: PageTransitionType.fade,
          duration: 800.ms,
          settings: const RouteSettings(name: '/bottom_nav'),
        ),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        _redirect();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page == 1.0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Hero(
            tag: 'NetflixLogo',
            child: Image.asset(
              Assets.viovidLogo,
              width: 140,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text(
                'Trợ giúp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: PageView(
          controller: _pageController,
          children: [
            SignInScreen(pageController: _pageController),
            const SignUpScreen(),
          ],
        ),
      ),
    );
  }
}
