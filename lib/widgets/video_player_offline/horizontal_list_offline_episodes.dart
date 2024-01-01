import 'package:flutter/material.dart';
import 'package:movie_app/models/offfline_season.dart';
import 'package:movie_app/widgets/video_player_offline/downloaded_episode_ui_second.dart';

class HorizontalListOfflineEpisodes extends StatefulWidget {
  const HorizontalListOfflineEpisodes(
    this.filmId,
    this.seasons, {
    required this.seasonsIndex,
    super.key,
  });

  final String filmId;
  final List<OfflineSeason> seasons;
  final int seasonsIndex;

  @override
  State<HorizontalListOfflineEpisodes> createState() =>
      _HorizontalListOfflineEpisodesState();
}

class _HorizontalListOfflineEpisodesState extends State<HorizontalListOfflineEpisodes> {
  late int currentSeasonIndex = widget.seasonsIndex;

  @override
  Widget build(BuildContext context) {
    final episodes = widget.seasons[currentSeasonIndex].offlineEpisodes;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 4),
                  itemBuilder: (ctx) => List.generate(
                    widget.seasons.length,
                    (index) => PopupMenuItem(
                      onTap: () {
                        setState(() {
                          currentSeasonIndex = index;
                        });
                      },
                      child: Text(widget.seasons[index].name),
                    ),
                  ),
                  tooltip: '',
                  child: Ink(
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                    child: Text(
                      widget.seasons[currentSeasonIndex].name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) => DownloadedEpisodeUISecond(
                  /* 
                  Truyền filmId vào để DownloadedEpisodeUISecond có thể truy xuất được 
                  đường link dẫn đến nơi lưu episode và stillPath
                  */
                  filmId: widget.filmId,
                  offlineEpisode: episodes[index],
                  // seasonIndex là số thứ tự season chứa tập phim này
                  seasonIndex: currentSeasonIndex,
                  isEpisodeDownloaded: false,
                ),
                itemCount: episodes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
