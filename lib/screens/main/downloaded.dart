import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/data/downloaded_film.dart';
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
  bool _isMultiSelectMode = false;
  final _movieListKey = GlobalKey<AnimatedListState>();
  final _tvListKey = GlobalKey<AnimatedListState>();
  final _selectedMovieIds = <String>[];
  final _selectedTvIds = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                  });
                },
                icon: const Icon(Icons.cancel_outlined),
                padding: const EdgeInsets.all(16),
              ).animate().scale()
            : currentPage == 0
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
        title: Text(
          currentPage == 0 ? 'Tệp tải xuống' : selectedTv['film_name'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: _isMultiSelectMode
            ? [
                IconButton(
                  onPressed: () {
                    for (final movieId in _selectedMovieIds) {
                      final index =
                          offlineMovies.indexWhere((movie) => movie['id'] == movieId);
                      offlineMovies.removeAt(index);
                      _movieListKey.currentState!.removeItem(
                        index,
                        (context, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: const SizedBox(
                            height: 166,
                          ),
                        ),
                      );
                    }
                    for (final tvId in _selectedTvIds) {
                      final index = offlineTvs.indexWhere((tv) => tv['id'] == tvId);
                      offlineTvs.removeAt(index);
                      _tvListKey.currentState!.removeItem(
                        index,
                        (context, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: const SizedBox(
                            height: 166,
                          ),
                        ),
                      );
                    }
                    setState(() {
                      _selectedMovieIds.clear();
                      _selectedTvIds.clear();
                      _isMultiSelectMode = false;
                    });
                  },
                  icon: const Icon(Icons.delete),
                ).animate().scale(),
              ]
            : null,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          AllDownloadedFilm(
            onSelectTv: (tv) {
              selectedTv = tv;
              setState(() {
                currentPage = 1;
              });
            },
            isMultiSelectMode: _isMultiSelectMode,
            turnOnMultiSelectMode: () => setState(() {
              _isMultiSelectMode = true;
            }),
            movieListKey: _movieListKey,
            tvListKey: _tvListKey,
            onMultiSelect: (type, filmId) => {
              type == 'movie' ? _selectedMovieIds.add(filmId) : _selectedTvIds.add(filmId)
            },
            unMultiSelect: (type, filmId) => {
              type == 'movie'
                  ? _selectedMovieIds.remove(filmId)
                  : _selectedTvIds.remove(filmId)
            },
          ),
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
