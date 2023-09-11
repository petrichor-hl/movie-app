import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_episode.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tệp tải xuống'),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _ListAllDownloadedFilm(),
            _ListAllEpisode(),
          ],
        ));
  }
}

class _ListAllDownloadedFilm extends StatelessWidget {
  const _ListAllDownloadedFilm();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      children: [
        const Text(
          'Phim',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ...getMovies().map(
          (movie) => buildMovieItem(
            movie['film_name'],
            movie['poster_path'],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'TV Series',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ...getTvSeries().map(
          (movie) => buildTvSeriesItem(
            movie['film_name'],
            movie['poster_path'],
          ),
        ),
      ],
    );
  }

  Widget buildMovieItem(String name, String posterPath) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(posterPath),
            width: 110,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '29 minutes',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildTvSeriesItem(String name, String posterPath) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(posterPath),
            width: 110,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _ListAllEpisode extends StatelessWidget {
  const _ListAllEpisode();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      color: Colors.deepPurple,
    );
  }
}
