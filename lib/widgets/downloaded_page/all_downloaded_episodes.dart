import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/widgets/downloaded_page/downloaded_episode.dart';

class AllDownloadedEpisode extends StatelessWidget {
  const AllDownloadedEpisode(
    this.selectedTv, {
    super.key,
  });

  final Map<String, dynamic> selectedTv;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> seasons = selectedTv['seasons'] ?? [];

    return Scaffold(
      body: SizedBox.expand(
        child: selectedTv.isEmpty
            ? null
            : ListView(
                children: List.generate(seasons.length, (index) {
                  final season = seasons[index];
                  final animatedKey = GlobalKey<AnimatedListState>();
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
                      AnimatedList(
                        key: animatedKey,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        initialItemCount: episodes.length,
                        itemBuilder: (ctx, index, animation) {
                          final episodeFile = File(
                            '${appDir.path}/episode/${selectedTv['id']}/${episodes[index]['id']}.mp4',
                          );
                          return DownloadedEpisode(
                            episodeId: episodes[index]['id'],
                            title: episodes[index]['title'],
                            order: episodes[index]['order'],
                            stillPath: episodes[index]['still_path'],
                            runtime: episodes[index]['runtime'],
                            fileSize: episodeFile.lengthSync(),
                            seasonId: season['id'],
                            filmId: selectedTv['id'],
                            posterPath: selectedTv['poster_path'],
                            episodeListKey: animatedKey,
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
