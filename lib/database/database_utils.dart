import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';

class DatabaseUtils {
  late Database _database;

  Future<void> connect() async {
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      '$databasePath/movie.db',
      onCreate: (db, version) async {
        await db.execute(
          '''
        CREATE TABLE film(
          id TEXT PRIMARY KEY, 
          name TEXT, 
          poster_path TEXT
        )''',
        );
        await db.execute(
          '''
        CREATE TABLE season(
          id TEXT PRIMARY KEY, 
          name TEXT, 
          film_id TEXT
        )''',
        );
        await db.execute(
          '''
        CREATE TABLE episode(
          id TEXT PRIMARY KEY, 
          episodeOrder INT,
          title TEXT, 
          runtime INT,
          still_path TEXT,
          season_id TEXT
        )''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertFilm(
    String id,
    String name,
    String posterPath,
  ) async {
    await _database.insert(
      'film',
      {
        'id': id,
        'name': name,
        'poster_path': posterPath,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertSeason({
    required String id,
    String name = '',
    required String filmId,
  }) async {
    await _database.insert(
      'season',
      {
        'id': id,
        'name': name,
        'film_id': filmId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertEpisode({
    required String id,
    int order = 1,
    String title = '',
    required int runtime,
    String stillPath = '',
    required String seasonId,
  }) async {
    await _database.insert(
      'episode',
      {
        'id': id,
        'episodeOrder': order,
        'title': title,
        'runtime': runtime,
        'still_path': stillPath,
        'season_id': seasonId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> queryFilms() async {
    return await _database.rawQuery('select * from film');
  }

  Future<List<Map<String, dynamic>>> querySeasons() async {
    return await _database.rawQuery('select * from season');
  }

  Future<List<Map<String, dynamic>>> queryEpisodes() async {
    return await _database.rawQuery(
      'select id, episodeOrder as \'order\', title, runtime, still_path, season_id from episode',
    );
  }

  Future<void> deleteEpisode({
    required String id,
    required String seasonId,
    required String filmId,
    required Future<void> Function() clean,
  }) async {
    await _database.delete(
      'episode',
      where: 'id = ?',
      whereArgs: [id],
    );

    final episodesOfSeason = firstIntValue(await _database.rawQuery(
      'select count(id) from episode where season_id = ?',
      [seasonId],
    ));

    if (episodesOfSeason != 0) {
      return;
    }

    await _database.delete(
      'season',
      where: 'id = ?',
      whereArgs: [seasonId],
    );

    final seasonsOfFilm = firstIntValue(await _database.rawQuery(
      'select count(id) from season where film_id = ?',
      [filmId],
    ));

    if (seasonsOfFilm != 0) {
      return;
    }

    await _database.delete(
      'film',
      where: 'id = ?',
      whereArgs: [filmId],
    );

    await clean();
  }

  Future<void> close() async {
    await _database.close();
  }
}
