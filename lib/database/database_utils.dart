import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  late final Database database;

  Future<void> connect() async {
    final databasePath = await getDatabasesPath();
    database = await openDatabase(
      '$databasePath/movie.db',
      onCreate: (database, version) async {
        await database.execute(
          '''
        CREATE TABLE film(
          id TEXT PRIMARY KEY, 
          name TEXT, 
          backdrop_path TEXT
        )''',
        );
        await database.execute(
          '''
        CREATE TABLE season(
          id TEXT PRIMARY KEY, 
          name TEXT, 
          film_id TEXT
        )''',
        );
        await database.execute(
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
    await database.insert(
      'film',
      {
        'id': id,
        'name': name,
        'backdrop_path': backdropPath,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertSeason(
    String id,
    String name,
    String filmId,
  ) async {
    await database.insert(
      'season',
      {
        'id': id,
        'name': name,
        'film_id': filmId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertEpisode(
    String id,
    String title,
    int runtime,
    String stillPath,
    String seasonId,
  ) async {
    await database.insert(
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
}
