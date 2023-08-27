import 'package:flutter/material.dart';

import 'package:movie_app/assets.dart';

import 'package:movie_app/screens/auth/sign_in.dart';
import 'package:movie_app/screens/auth/sign_up.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final _pageController = PageController();

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
              Assets.netflixLogo,
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
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              children: [
                SignInScreen(pageController: _pageController),
                const SignUpScreen(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
