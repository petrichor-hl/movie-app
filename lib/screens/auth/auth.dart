import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
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
    await getDownloadedFilms();
    if (mounted) {
      context.read<MyListCubit>().setList(await fetchMyList());
    }
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => const BottomNavScreen()),
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
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
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
