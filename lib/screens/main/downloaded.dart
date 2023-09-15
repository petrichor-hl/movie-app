import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
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
                  onPressed: () async {
                    // Xoá movie
                    for (final movieId in _selectedMovieIds) {
                      // 1. Xoá trong Application Directory
                      final index = offlineMovies.indexWhere(
                        (movie) => movie['id'] == movieId,
                      );
                      final episodeId =
                          offlineMovies[index]['seasons'][0]['episodes'][0]['id'];

                      final episodeFile = File('${appDir.path}/episode/$episodeId.mp4');
                      await episodeFile.delete();

                      // 2. Xoá movie trong database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      await databaseUtils.deleteEpisode(
                        id: episodeId,
                        seasonId: offlineMovies[index]['seasons'][0]['id'],
                        filmId: offlineMovies[index]['id'],
                        deletePosterPath: () async {
                          final posterFile = File(
                            '${appDir.path}/poster_path/${offlineMovies[index]['poster_path']}',
                          );
                          await posterFile.delete();
                        },
                      );
                      await databaseUtils.close();

                      // 3. Xoá movie trong app's memory
                      episodeIds.remove(episodeId);
                      offlineMovies.removeAt(index);
                    }

                    // Remove TV
                    for (final tvId in _selectedTvIds) {
                      // 1. Xoá trong Application Directory
                      final index = offlineTvs.indexWhere(
                        (tv) => tv['id'] == tvId,
                      );
                      print('film_name = ${offlineTvs[index]['film_name']}');
                      final filmId = offlineTvs[index]['id'];

                      final episodeDirectory =
                          Directory('${appDir.path}/episode/$filmId');
                      await episodeDirectory.delete(recursive: true);
                      final stillPathDirectory =
                          Directory('${appDir.path}/still_path/$filmId');
                      await stillPathDirectory.delete(recursive: true);

                      // 2. Xoá Tv trong database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      for (final season in offlineTvs[index]['seasons']) {
                        for (final episode in season['episodes']) {
                          await databaseUtils.deleteEpisode(
                            id: episode['id'],
                            seasonId: season['id'],
                            filmId: filmId,
                            deletePosterPath: () async {
                              final posterFile = File(
                                '${appDir.path}/poster_path/${offlineTvs[index]['poster_path']}',
                              );
                              await posterFile.delete();
                            },
                          );
                          // 3. Xoá movie trong app's memory
                          episodeIds.remove(episode['id']);
                        }
                      }
                      await databaseUtils.close();

                      offlineTvs.removeAt(index);
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
