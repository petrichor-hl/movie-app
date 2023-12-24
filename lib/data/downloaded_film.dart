import 'dart:io';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/offfline_season.dart';
import 'package:movie_app/models/offline_episode.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:path_provider/path_provider.dart';

final Map<String, OfflineFilm> downloadedFilms = {};

late Directory appDir;

Future<void> getDownloadedFilms() async {
  final databaseUtils = DatabaseUtils();
  await databaseUtils.connect();

  final films = await databaseUtils.queryFilms();
  final seasons = await databaseUtils.querySeasons();
  final episodes = await databaseUtils.queryEpisodes();

  await databaseUtils.close();

  appDir = await getApplicationDocumentsDirectory();
  print('app dir: ${appDir.path}');

  // print('episode_ids = $episodeIds');

  for (final film in films) {
    final offlineFilm = OfflineFilm(
      id: film['id'],
      name: film['name'],
      posterPath: film['poster_path'],
      offlineSeasons: [],
    );
    for (final season in seasons) {
      if (season['film_id'] == film['id']) {
        offlineFilm.offlineSeasons.add(
          OfflineSeason(
            seasonId: season['id'],
            name: season['name'],
            offlineEpisodes: episodes
                .where((episode) => episode['season_id'] == season['id'])
                .map(
                  (episode) => OfflineEpisode(
                    episodeId: episode['id'],
                    order: episode['order'],
                    title: episode['title'],
                    runtime: episode['runtime'],
                    stillPath: episode['still_path'],
                  ),
                )
                .toList(),
          ),
        );
      }
    }
    downloadedFilms[offlineFilm.id] = offlineFilm;
  }
  // downloadedFilms.forEach((key, value) {
  //   print(value.name);
  // });
}
