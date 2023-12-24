import 'package:movie_app/models/offfline_season.dart';

class OfflineFilm {
  String id;
  String name;
  String posterPath;
  List<OfflineSeason> offlineSeasons;

  OfflineFilm({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.offlineSeasons,
  });
}
