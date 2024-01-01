import 'package:flutter/material.dart';
import 'package:movie_app/models/season.dart';
import 'package:movie_app/widgets/video_player/episode_ui_second.dart';

class HorizontalListEpisodes extends StatefulWidget {
  const HorizontalListEpisodes(
    this.seasons, {
    required this.seasonsIndex,
    super.key,
  });

  final List<Season> seasons;
  final int seasonsIndex;

  @override
  State<HorizontalListEpisodes> createState() => _HorizontalListEpisodesState();
}

class _HorizontalListEpisodesState extends State<HorizontalListEpisodes> {
  late int currentSeasonIndex = widget.seasonsIndex;

  @override
  Widget build(BuildContext context) {
    final episodes = widget.seasons[currentSeasonIndex].episodes;
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
                itemBuilder: (ctx, index) => EpisodeUISecond(
                  episode: episodes[index],
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
