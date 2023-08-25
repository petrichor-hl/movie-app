import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    axisDirection: Axis.horizontal,
                    effect: WormEffect(
                      spacing: 10,
                      radius: 5,
                      dotWidth: 10,
                      dotHeight: 10,
                      paintStyle: PaintingStyle.fill,
                      dotColor: Colors.grey,
                      activeDotColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('ĐĂNG NHẬP'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
