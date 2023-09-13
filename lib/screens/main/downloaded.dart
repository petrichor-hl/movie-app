import 'package:flutter/material.dart';
import 'package:movie_app/widgets/downloaded_page/all_downloaded_episodes.dart';
import 'package:movie_app/widgets/downloaded_page/all_downloaded_films.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen> {
  int currentPage = 0;
  Map<String, dynamic> selectedTv = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: currentPage == 0
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    currentPage = 0;
                  });
                },
                icon: const Icon(Icons.arrow_back_ios),
                padding: const EdgeInsets.all(16),
              ),
        leadingWidth: 56,
        title: Text(
          currentPage == 0 ? 'Tệp tải xuống' : selectedTv['film_name'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          AllDownloadedFilm(onSelectTv: (tv) {
            selectedTv = tv;
            setState(() {
              currentPage = 1;
            });
          }),
          AnimatedSlide(
            offset: currentPage == 0 ? const Offset(1, 0) : const Offset(0, 0),
            duration: const Duration(milliseconds: 240),
            child: AllDownloadedEpisode(
              selectedTv,
              backToAllDownloadedFilm: () => setState(() {
                currentPage = 0;
              }),
            ),
          ),
        ],
      ),
    );
  }
}

String formatBytes(int bytes) {
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  double fileSize = bytes.toDouble();

  while (fileSize >= 1024 && i < sizes.length - 1) {
    fileSize /= 1024;
    i++;
  }

  return '${fileSize.toInt()} ${sizes[i]}';
}
