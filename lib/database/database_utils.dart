import 'package:sqflite/sqflite.dart';

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
          backdrop_path TEXT
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
    String backdropPath,
  ) async {
    await _database.insert(
      'film',
      {
        'id': id,
        'name': name,
        'backdrop_path': backdropPath,
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
    String title = '',
    required int runtime,
    String stillPath = '',
    required String seasonId,
  }) async {
    await _database.insert(
      'episode',
      {
        'id': id,
        'title': title,
        'runtime': runtime,
        'still_path': stillPath,
        'season_id': seasonId,
      },
    );
  }

  Future<void> deleteEpisode({
    required String id,
    required String seasonId,
    required String filmId,
    required Future<void> Function() deleteBackdropPath,
  }) async {
    await _database.delete(
      'episode',
      where: 'id = ?',
      whereArgs: [id],
    );

    final episodesOfSeason = (await _database.rawQuery(
      'select count(id) from episode where season_id = ?',
      [seasonId],
    ))[0]['count(id)'];

    if (episodesOfSeason != 0) {
      return;
    }

    await _database.delete(
      'season',
      where: 'id = ?',
      whereArgs: [seasonId],
    );

    final seasonsOfFilm = (await _database.rawQuery(
      'select count(id) from season where film_id = ?',
      [filmId],
    ))[0]['count(id)'];

    if (seasonsOfFilm != 0) {
      return;
    }

    await _database.delete(
      'film',
      where: 'id = ?',
      whereArgs: [filmId],
    );

    await deleteBackdropPath();
  }

  Future<void> close() async {
    await _database.close();
  }
}
