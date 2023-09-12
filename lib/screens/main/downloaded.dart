import 'package:flutter/material.dart';
import 'package:movie_app/widgets/downloaded_page/all_downloaded_episodes.dart';
import 'package:movie_app/widgets/downloaded_page/all_downloaded_films.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen> {
  final _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page == 0 || _pageController.page == 1) {
        setState(() {
          currentPage = _pageController.page!.toInt();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: currentPage == 0
              ? null
              : IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                  padding: const EdgeInsets.all(16),
                ),
          leadingWidth: 56,
          title: const Text('Tệp tải xuống'),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ListAllDownloadedFilm(pageController: _pageController),
            const ListAllEpisode(),
          ],
        ));
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
