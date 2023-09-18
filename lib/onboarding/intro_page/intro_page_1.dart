import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/intro_page/intro_page_1.jpeg',
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
                  'Xem trên bất kỳ thiết bị nào',
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
                  'Phát trực tuyến trên điện thoại, máy tính bảng, laptop và TV của bạn mà không cần trả thêm phí.',
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
