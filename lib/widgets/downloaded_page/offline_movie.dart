import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_episode.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/screens/main/downloaded.dart';

class OfflineMovie extends StatelessWidget {
  const OfflineMovie({
    super.key,
    required this.episodeId,
    required this.seasonId,
    required this.filmId,
    required this.filmName,
    required this.posterPath,
    required this.runtime,
    required this.fileSize,
    required this.movieListKey,
  });

  final String episodeId;
  final String seasonId;
  final String filmId;
  final String filmName;
  final String posterPath;
  final int runtime;
  final int fileSize;
  final GlobalKey<AnimatedListState> movieListKey;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File('${appDir.path}/poster_path/$posterPath'),
              height: 150,
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
                  filmName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$runtime phút',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  formatBytes(fileSize),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (ctx) {
          return [
            const PopupMenuItem(
              value: 0,
              child: Text('Xoá tệp tải xuống'),
            ),
          ];
        },
        icon: const Icon(Icons.download_done),
        iconSize: 28,
        color: Colors.white,
        tooltip: '',
        onSelected: (_) async {
          // Delete Movie

          // print('remove film: $filmName');

          final episodeFile = File('${appDir.path}/episode/$episodeId.mp4');
          await episodeFile.delete();

          final databaseUtils = DatabaseUtils();
          await databaseUtils.connect();
          await databaseUtils.deleteEpisode(
            id: episodeId,
            seasonId: seasonId,
            filmId: filmId,
            deletePosterPath: () async {
              final posterFile = File('${appDir.path}/poster_path/$posterPath');
              await posterFile.delete();
            },
          );
          await databaseUtils.close();

          episodeIds.remove(episodeId);
          // offlineMovies.removeAt(movieIndex);

          final index = offlineMovies.indexWhere((element) => element['id'] == filmId);

          movieListKey.currentState!.removeItem(
            index,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: this,
            ),
          );

          offlineMovies.removeAt(index);
        },
      ),
    );
  }
}
