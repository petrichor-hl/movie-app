import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:movie_app/widgets/downloaded_page/offline_movie_ui.dart';
import 'package:movie_app/widgets/downloaded_page/offline_tv_ui.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen> {
  final _offlineMovies = <OfflineFilm>[];
  final _offlineTvs = <OfflineFilm>[];

  bool _isMultiSelectMode = false;

  // Lưu id của các phim được chọn trong Multi Select Mode
  final _selectedMovieIds = <String>[];
  final _selectedTvIds = <String>[];

  @override
  void initState() {
    super.initState();
    for (var downloadedFilm in downloadedFilms.values) {
      if (downloadedFilm.offlineSeasons[0].name.isEmpty) {
        _offlineMovies.add(downloadedFilm);
      } else {
        _offlineTvs.add(downloadedFilm);
      }
    }
    /* 
    Lưu ý:
    Khi xoá item trong downloadedFilm
    thì offlineMovies, offlineTvs không bị ảnh hưởng
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedMovieIds.clear();
                    _selectedTvIds.clear();
                  });
                },
                icon: const Icon(Icons.cancel),
                padding: const EdgeInsets.all(16),
              ).animate().scale()
            : null,
        title: const Text(
          'Tệp tải xuống',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _isMultiSelectMode
            ? [
                IconButton(
                  onPressed: () async {
                    // Remove Movie
                    for (final movieId in _selectedMovieIds) {
                      // 1. Xoá trong Application Directory
                      final index = _offlineMovies.indexWhere(
                        (offlineMovie) => offlineMovie.id == movieId,
                      );
                      final episodeId = _offlineMovies[index]
                          .offlineSeasons[0]
                          .offlineEpisodes[0]
                          .episodeId;

                      final episodeFile = File('${appDir.path}/episode/$episodeId.mp4');
                      await episodeFile.delete();

                      // 2. Xoá movie trong database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      await databaseUtils.deleteEpisode(
                        id: episodeId,
                        seasonId: _offlineMovies[index].offlineSeasons[0].seasonId,
                        filmId: _offlineMovies[index].id,
                        clean: () async {
                          final posterFile = File(
                            '${appDir.path}/poster_path/${_offlineMovies[index].posterPath}',
                          );
                          await posterFile.delete();
                        },
                      );
                      await databaseUtils.close();

                      // 3. Xoá movie trong app's memory
                      _offlineMovies.removeAt(index);
                      downloadedFilms.remove(movieId);
                    }

                    // Remove TV
                    for (final tvId in _selectedTvIds) {
                      // 1. Xoá trong Application Directory
                      final index = _offlineTvs.indexWhere(
                        (offlineTv) => offlineTv.id == tvId,
                      );
                      final filmId = _offlineTvs[index].id;

                      //  Xoá thư mục Tập phim
                      final episodeDirectory =
                          Directory('${appDir.path}/episode/$filmId');
                      await episodeDirectory.delete(recursive: true);

                      //  Xoá thư mục Still Path
                      final stillPathDirectory =
                          Directory('${appDir.path}/still_path/$filmId');
                      await stillPathDirectory.delete(recursive: true);

                      // 2. Xoá Tv trong database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();

                      for (final season in _offlineTvs[index].offlineSeasons) {
                        for (final episode in season.offlineEpisodes) {
                          await databaseUtils.deleteEpisode(
                            id: episode.episodeId,
                            seasonId: season.seasonId,
                            filmId: filmId,
                            clean: () async {
                              final posterFile = File(
                                '${appDir.path}/poster_path/${_offlineTvs[index].posterPath}',
                              );
                              await posterFile.delete();
                            },
                          );
                        }
                      }
                      await databaseUtils.close();

                      // 3. Xoá movie trong app's memory
                      downloadedFilms.remove(tvId);
                      _offlineTvs.removeAt(index);
                    }

                    setState(() {
                      _selectedMovieIds.clear();
                      _selectedTvIds.clear();
                      _isMultiSelectMode = false;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xoá các tệp phim'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_rounded),
                  padding: const EdgeInsets.all(16),
                ).animate().scale(),
              ]
            : null,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'Phim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Gap(4),
            Column(
              children: List.generate(
                _offlineMovies.length,
                (index) {
                  final offlineMovie = _offlineMovies[index];
                  final season = offlineMovie.offlineSeasons[0];
                  final episode = season.offlineEpisodes[0];
                  final episodeFile =
                      File('${appDir.path}/episode/${episode.episodeId}.mp4');
                  return OfflineMovieUI(
                    key: ValueKey(offlineMovie.id),
                    offlineMovie: offlineMovie,
                    isMultiSelectMode: _isMultiSelectMode,
                    turnOnMultiSelectMode: () => setState(() {
                      _isMultiSelectMode = true;
                    }),
                    onSelectItemInMultiMode: () => _selectedMovieIds.add(offlineMovie.id),
                    unSelectItemInMultiMode: () =>
                        _selectedMovieIds.remove(offlineMovie.id),
                    fileSize: episodeFile.lengthSync(),
                    onIndividualDelete: () {
                      downloadedFilms.remove(offlineMovie.id);
                      _offlineMovies.removeAt(index);
                      // print("downloadedFilms.length = ${downloadedFilms.length}");
                      // print("offlineMovies.length = ${offlineMovies.length}");
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            const Gap(12),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'TV Series',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Gap(4),
            Column(
              children: List.generate(
                _offlineTvs.length,
                (index) {
                  final offlineTv = _offlineTvs[index];

                  final episodeFolderOfTv =
                      Directory('${appDir.path}/episode/${offlineTv.id}');

                  int totalSize = 0;
                  final entities = episodeFolderOfTv.listSync();

                  for (final entity in entities) {
                    final File file = File(entity.path);
                    totalSize += file.lengthSync();
                  }
                  return OfflineTvUI(
                    key: ValueKey(offlineTv),
                    offlineTv: offlineTv,
                    episodeCount: entities.length,
                    allEpisodesSize: totalSize,
                    isMultiSelectMode: _isMultiSelectMode,
                    turnOnMultiSelectMode: () => setState(() {
                      _isMultiSelectMode = true;
                    }),
                    onSelectItemInMultiMode: () => _selectedTvIds.add(offlineTv.id),
                    unSelectItemInMultiMode: () => _selectedTvIds.remove(offlineTv.id),
                    reloadDownloadedPage: () => setState(() {
                      _offlineTvs.removeWhere((element) => element.id == offlineTv.id);
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
