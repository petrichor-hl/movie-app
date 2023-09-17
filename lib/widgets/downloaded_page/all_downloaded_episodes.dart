import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/widgets/downloaded_page/downloaded_episode.dart';

class AllDownloadedEpisode extends StatefulWidget {
  const AllDownloadedEpisode(
    this.selectedTv, {
    super.key,
    required this.backToAllDownloadedFilm,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.onSelectItemInMultiMode,
    required this.unSelectItemInMultiMode,
  });

  final Map<String, dynamic> selectedTv;
  final void Function() backToAllDownloadedFilm;
  final bool isMultiSelectMode;
  final void Function({required String fromPage}) turnOnMultiSelectMode;
  final void Function(String filmType, String episodeId) onSelectItemInMultiMode;
  final void Function(String filmType, String episodeId) unSelectItemInMultiMode;

  @override
  State<AllDownloadedEpisode> createState() => _AllDownloadedEpisodeState();
}

class _AllDownloadedEpisodeState extends State<AllDownloadedEpisode> {
  @override
  Widget build(BuildContext context) {
    final List<dynamic> seasons = widget.selectedTv['seasons'] ?? [];

    return Scaffold(
      body: SizedBox.expand(
        child: widget.selectedTv.isEmpty
            ? null
            : ListView(
                children: List.generate(seasons.length, (index) {
                  final season = seasons[index];
                  final List<Map<String, dynamic>> episodes = season['episodes'];
                  episodes.sort(
                    (a, b) => (a['order'] as int).compareTo(b['order']),
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          season['season_name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: episodes.length,
                        itemBuilder: (ctx, index) {
                          final episodeFile = File(
                            '${appDir.path}/episode/${widget.selectedTv['id']}/${episodes[index]['id']}.mp4',
                          );

                          return DownloadedEpisode(
                            episodeId: episodes[index]['id'],
                            title: episodes[index]['title'],
                            order: episodes[index]['order'],
                            stillPath: episodes[index]['still_path'],
                            runtime: episodes[index]['runtime'],
                            fileSize: episodeFile.lengthSync(),
                            seasonId: season['id'],
                            filmId: widget.selectedTv['id'],
                            posterPath: widget.selectedTv['poster_path'],
                            onDeleteSeason: () => setState(() {}),
                            backToAllDownloadedFilm: widget.backToAllDownloadedFilm,
                            onIndividualDelete: () => setState(() {}),
                            isMultiSelectMode: widget.isMultiSelectMode,
                            turnOnMultiSelectMode: () => widget.turnOnMultiSelectMode(
                              fromPage: "all_downloaded_episodes",
                            ),
                            onSelectItemInMultiMode: () => widget.onSelectItemInMultiMode(
                                'episode', season['id'] + '/' + episodes[index]['id']),
                            unSelectItemInMultiMode: () => widget.unSelectItemInMultiMode(
                                'episode', season['id'] + '/' + episodes[index]['id']),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),
      ),
    );
  }
}
