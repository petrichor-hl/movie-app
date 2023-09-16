import 'dart:io';
import 'package:movie_app/database/database_utils.dart';
import 'package:path_provider/path_provider.dart';

List<Map<String, dynamic>> offlineMovies = [];
List<Map<String, dynamic>> offlineTvs = [];

late final List<String> episodeIds;
late final Directory appDir;

Future<void> getDownloadedFilms() async {
  final databaseUtils = DatabaseUtils();
  await databaseUtils.connect();

  final films = await databaseUtils.queryFilms();
  final seasons = await databaseUtils.querySeasons();
  final episodes = await databaseUtils.queryEpisodes();

  await databaseUtils.close();

  appDir = await getApplicationDocumentsDirectory();
  print('app dir: ${appDir.path}');

  episodeIds = List.generate(
    episodes.length,
    (index) => episodes[index]['id'],
  );
  // print('episode_ids = $episodeIds');

  for (final film in films) {
    final filmData = {
      'id': film['id'],
      'film_name': film['name'],
      'poster_path': film['poster_path'],
    };
    final filteredSeason = [];
    for (final season in seasons) {
      if (season['film_id'] == film['id']) {
        final seasonData = {
          'id': season['id'],
          'season_name': season['name'],
          'episodes':
              episodes.where((episode) => episode['season_id'] == season['id']).toList(),
        };
        filteredSeason.add(seasonData);
      }
    }
    filmData['seasons'] = filteredSeason;

    if (filteredSeason[0]['season_name'] == "") {
      offlineMovies.add(filmData);
    } else {
      offlineTvs.add(filmData);
    }
  }
}

// List<Map<String, dynamic>> getMovies() {
//   final List<Map<String, dynamic>> movies = [];
//   for (var film in offlineFilms) {
//     if (film['seasons'][0]['season_name'] == '') {
//       movies.add(film);
//     }
//   }

//   return movies;
// }

// List<Map<String, dynamic>> getTvSeries() {
//   final List<Map<String, dynamic>> tvSeries = [];
//   for (var film in offlineFilms) {
//     if (film['seasons'][0]['season_name'] != '') {
//       tvSeries.add(film);
//     }
//   }

//   return tvSeries;
// }
