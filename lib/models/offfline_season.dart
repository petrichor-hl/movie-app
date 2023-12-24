import 'package:movie_app/models/offline_episode.dart';

class OfflineSeason {
  String seasonId;
  String name;
  List<OfflineEpisode> offlineEpisodes;

  OfflineSeason({
    required this.seasonId,
    required this.name,
    required this.offlineEpisodes,
  });
}
