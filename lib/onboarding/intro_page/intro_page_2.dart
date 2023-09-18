import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/intro_page/intro_page_2.jpeg',
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black87,
                Colors.transparent,
                Colors.black45,
                Colors.black87,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const Align(
          alignment: Alignment(0, 0.25),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tải xuống và xem ngoại tuyến',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Tiết kiệm dung lượng, xem ngoại tuyến trên máy bay, tàu lửa hoặc tàu ngầm ...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
