import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/screens/main/downloaded.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';

class DownloadedEpisode extends StatelessWidget {
  const DownloadedEpisode({
    super.key,
    required this.episodeId,
    required this.title,
    required this.order,
    required this.stillPath,
    required this.runtime,
    required this.fileSize,
    required this.seasonId,
    required this.filmId,
    required this.posterPath,
    required this.onDeleteSeason,
    required this.episodeListKey,
    required this.backToAllDownloadedFilm,
  });

  final String episodeId;
  final String title;
  final int order;
  final String stillPath;
  final int runtime;
  final int fileSize;
  final String seasonId;
  final String filmId;
  final String posterPath;
  final void Function() onDeleteSeason;
  final void Function() backToAllDownloadedFilm;
  final GlobalKey<AnimatedListState> episodeListKey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (ctx) => VideoSliderCubit(),
                ),
                BlocProvider(
                  create: (ctx) => VideoPlayControlCubit(),
                ),
              ],
              child: VideoPlayerView(
                title: title,
                videoLink: '${appDir.path}/episode/$filmId/$episodeId.mp4',
                videoLocation: 'local',
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Image.file(
                    File(
                      '${appDir.path}/still_path/$stillPath',
                    ),
                    width: 150,
                  ),
                  Container(
                    height: 28,
                    width: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      order.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$runtime phút | ${formatBytes(fileSize)}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            PopupMenuButton(
              itemBuilder: (ctx) {
                return [
                  const PopupMenuItem(
                    value: 0,
                    child: Text('Xoá tệp tải xuống'),
                  ),
                ];
              },
              icon: const Icon(Icons.download_done),
              iconSize: 28,
              color: Colors.white,
              tooltip: '',
              onSelected: (_) async {
                final episodeFile = File('${appDir.path}/episode/$filmId/$episodeId.mp4');
                await episodeFile.delete();

                final stillPathFile = File('${appDir.path}/still_path/$stillPath');
                await stillPathFile.delete();

                final databaseUtils = DatabaseUtils();
                await databaseUtils.connect();
                await databaseUtils.deleteEpisode(
                  id: episodeId,
                  seasonId: seasonId,
                  filmId: filmId,
                  deletePosterPath: () async {
                    final posterFile = File('${appDir.path}/poster_path/$posterPath');
                    await posterFile.delete();

                    final episodeTvDir = Directory('${appDir.path}/episode/$filmId');
                    await episodeTvDir.delete();
                  },
                );
                await databaseUtils.close();

                episodeIds.remove(episodeId);

                // remove data in offlineTvs
                final tvIndex = offlineTvs.indexWhere(
                  (tv) => tv['id'] == filmId,
                );

                final List seasons = offlineTvs[tvIndex]['seasons'];
                final seasonIndex = seasons.indexWhere(
                  (season) => season['id'] == seasonId,
                );

                final List episodes = seasons[seasonIndex]['episodes'];
                final episodeIndex = episodes.indexWhere(
                  (episode) => episode['id'] == episodeId,
                );
                episodes.removeWhere(
                  (episode) => episode['id'] == episodeId,
                );

                episodeListKey.currentState!.removeItem(
                  episodeIndex,
                  (context, animation) => SizeTransition(
                    sizeFactor: animation,
                    child: this,
                  ),
                  duration: const Duration(milliseconds: 300),
                );

                if (episodes.isEmpty) {
                  seasons.removeAt(seasonIndex);
                  await Future.delayed(const Duration(milliseconds: 300));
                  onDeleteSeason();
                  if (seasons.isEmpty) {
                    offlineTvs.removeAt(tvIndex);
                    backToAllDownloadedFilm();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
