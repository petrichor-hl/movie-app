import 'package:flutter/material.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Tải xuống',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
