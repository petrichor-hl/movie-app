import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/widgets/downloaded_page/offline_movie.dart';
import 'package:movie_app/widgets/downloaded_page/offline_tv.dart';

class AllDownloadedFilm extends StatelessWidget {
  const AllDownloadedFilm({
    super.key,
    required this.onSelectTv,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.movieListKey,
    required this.tvListKey,
    required this.onMultiSelect,
    required this.unMultiSelect,
  });
  final void Function(Map<String, dynamic>) onSelectTv;
  final bool isMultiSelectMode;
  final void Function() turnOnMultiSelectMode;
  final GlobalKey<AnimatedListState> movieListKey;
  final GlobalKey<AnimatedListState> tvListKey;
  final void Function(String filmType, String filmId) onMultiSelect;
  final void Function(String filmType, String filmId) unMultiSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        const SizedBox(
          height: 4,
        ),
        AnimatedList(
          key: movieListKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: offlineMovies.length,
          itemBuilder: (ctx, index, animation) {
            final movie = offlineMovies[index];
            final episodeId = movie['seasons'][0]['episodes'][0]['id'];
            final episodeFile = File('${appDir.path}/episode/$episodeId.mp4');
            return OfflineMovie(
              key: ValueKey(movie['id']),
              episodeId: episodeId,
              seasonId: movie['seasons'][0]['id'],
              filmId: movie['id'],
              filmName: movie['film_name'],
              posterPath: movie['poster_path'],
              runtime: movie['seasons'][0]['episodes'][0]['runtime'],
              fileSize: episodeFile.lengthSync(),
              movieListKey: movieListKey,
              isMultiSelectMode: isMultiSelectMode,
              turnOnMultiSelectMode: turnOnMultiSelectMode,
              onMultiSelect: () => onMultiSelect('movie', movie['id']),
              unMultiSelect: () => unMultiSelect('movie', movie['id']),
            );
          },
        ),
        const SizedBox(
          height: 12,
        ),
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
        const SizedBox(
          height: 4,
        ),
        AnimatedList(
          key: tvListKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: offlineTvs.length,
          itemBuilder: (ctx, index, animation) {
            final tv = offlineTvs[index];

            final episodeFolderOfTv = Directory('${appDir.path}/episode/${tv['id']}');

            int totalSize = 0;
            final entities = episodeFolderOfTv.listSync();

            for (final entity in entities) {
              final File file = File(entity.path);
              totalSize += file.lengthSync();
            }

            return OfflineTv(
              key: ValueKey(tv['id']),
              filmId: tv['id'],
              filmName: tv['film_name'],
              posterPath: tv['poster_path'],
              episodeCount: entities.length,
              allEpisodesSize: totalSize,
              tvListKey: tvListKey,
              isMultiSelectMode: isMultiSelectMode,
              turnOnMultiSelectMode: turnOnMultiSelectMode,
              onSelectTv: () => onSelectTv(tv),
              onMultiSelect: () => onMultiSelect('tv', tv['id']),
              unMultiSelect: () => unMultiSelect('tv', tv['id']),
            );
          },
        ),
      ],
    );
  }
}
