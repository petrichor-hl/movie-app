import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';
import 'package:path_provider/path_provider.dart';

enum DownloadState {
  ready,
  downloading,
  almostFinished,
  downloaded,
}

class Episode extends StatefulWidget {
  const Episode(
    this.episodeId,
    this.order,
    this.stillPath,
    this.title,
    this.runtime,
    this.subtitle,
    this.linkEpisode, {
    super.key,
  });

  final String episodeId;
  final int order;
  final String stillPath;
  final String title;
  final int runtime;
  final String subtitle;
  final String linkEpisode;

  @override
  State<Episode> createState() => _EpisodeState();
}

class _EpisodeState extends State<Episode> {
  late DownloadState downloadState = episodeIds.contains(widget.episodeId)
      ? DownloadState.downloaded
      : DownloadState.ready;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: InkWell(
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
                child: downloadState == DownloadState.ready
                    ? VideoPlayerView(
                        title: widget.title,
                        videoLink: widget.linkEpisode,
                      )
                    : VideoPlayerView(
                        title: widget.title,
                        videoLink:
                            '${appDir.path}/episode/${offlineData['film_id']}/${widget.episodeId}.mp4',
                        videoLocation: 'local',
                      ),
              ),
            ),
          );
        },
        splashColor: const Color.fromARGB(255, 52, 52, 52),
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    'https://www.themoviedb.org/t/p/w454_and_h254_bestv2${widget.stillPath}',
                    height: 80,
                    width: 143,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.runtime} phút',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (downloadState == DownloadState.ready)
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        downloadState = DownloadState.downloading;
                      });

                      final appDir = await getApplicationDocumentsDirectory();
                      // print('download to: $appDir');

                      // 1. download video
                      await Dio().download(
                        widget.linkEpisode,
                        '${appDir.path}/episode/${offlineData['film_id']}/${widget.episodeId}.mp4',
                        onReceiveProgress: (count, total) {
                          setState(() {
                            progress = count / total;
                          });
                        },
                        deleteOnError: true,
                      );

                      // print('added episode_id = ${widget.episodeId}');

                      // 2. download still_path
                      await Dio().download(
                        'https://www.themoviedb.org/t/p/w454_and_h254_bestv2/${widget.stillPath}',
                        '${appDir.path}/still_path${widget.stillPath}',
                        deleteOnError: true,
                      );

                      // 3. download film's backdrop_path
                      final posterLocalPath =
                          '${appDir.path}/poster_path/${offlineData['poster_path']}';
                      final file = File(posterLocalPath);
                      if (!await file.exists()) {
                        await Dio().download(
                          'https://image.tmdb.org/t/p/w440_and_h660_face/${offlineData['poster_path']}',
                          posterLocalPath,
                          deleteOnError: true,
                        );
                      }

                      // Insert data to local database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      await databaseUtils.insertFilm(offlineData['film_id'],
                          offlineData['film_name'], offlineData['poster_path']);

                      await databaseUtils.insertSeason(
                        id: offlineData['season_id'],
                        name: offlineData['season_name'],
                        filmId: offlineData['film_id'],
                      );

                      await databaseUtils.insertEpisode(
                        id: widget.episodeId,
                        order: widget.order,
                        title: widget.title,
                        runtime: widget.runtime,
                        stillPath: widget.stillPath,
                        seasonId: offlineData['season_id'],
                      );

                      await databaseUtils.close();
                      episodeIds.add(widget.episodeId);

                      final existingIndexTv = offlineTvs.indexWhere(
                        (tv) => tv['id'] == offlineData['film_id'],
                      );
                      if (existingIndexTv == -1) {
                        offlineTvs.add({
                          'id': offlineData['film_id'],
                          'film_name': offlineData['film_name'],
                          'poster_path': offlineData['poster_path'],
                          'seasons': [
                            {
                              'id': offlineData['season_id'],
                              'season_name': offlineData['season_name'],
                              'episodes': [
                                {
                                  'id': widget.episodeId,
                                  'order': widget.order,
                                  'still_path': widget.stillPath,
                                  'title': widget.title,
                                  'runtime': widget.runtime,
                                }
                              ],
                            }
                          ]
                        });
                      } else {
                        final Map<String, dynamic> existingTv =
                            offlineTvs[existingIndexTv];
                        final List<dynamic> seasons = existingTv['seasons'];
                        final existingIndexSeason = seasons.indexWhere(
                          (season) => season['id'] == offlineData['season_id'],
                        );

                        if (existingIndexSeason == -1) {
                          seasons.add({
                            'id': offlineData['season_id'],
                            'season_name': offlineData['season_name'],
                            'episodes': [
                              {
                                'id': widget.episodeId,
                                'order': widget.order,
                                'still_path': widget.stillPath,
                                'title': widget.title,
                                'runtime': widget.runtime,
                              }
                            ],
                          });
                        } else {
                          final Map existingSeason = seasons[existingIndexSeason];
                          final List episodes = existingSeason['episodes'];
                          episodes.add({
                            'id': widget.episodeId,
                            'order': widget.order,
                            'still_path': widget.stillPath,
                            'title': widget.title,
                            'runtime': widget.runtime,
                          });
                        }
                      }

                      setState(() {
                        downloadState = DownloadState.downloaded;
                      });
                    },
                    icon: const Icon(
                      Icons.download,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(foregroundColor: Colors.white),
                  ),
                if (downloadState == DownloadState.downloading)
                  Container(
                    height: 48,
                    width: 48,
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withAlpha(80),
                    ),
                  ),
                if (downloadState == DownloadState.downloaded)
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
                      final episodeFile = File(
                          '${appDir.path}/episode/${offlineData['film_id']}/${widget.episodeId}.mp4');
                      await episodeFile.delete();

                      final stillPathFile =
                          File('${appDir.path}/still_path/${widget.stillPath}');
                      await stillPathFile.delete();

                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      await databaseUtils.deleteEpisode(
                        id: widget.episodeId,
                        seasonId: offlineData['season_id'],
                        filmId: offlineData['film_id'],
                        deletePosterPath: () async {
                          final posterFile = File(
                              '${appDir.path}/poster_path/${offlineData['poster_path']}');
                          await posterFile.delete();

                          final episodeTvDir = Directory(
                              '${appDir.path}/episode/${offlineData['film_id']}');
                          await episodeTvDir.delete();
                        },
                      );
                      await databaseUtils.close();

                      episodeIds.remove(widget.episodeId);

                      // remove data in offlineTvs
                      final tvIndex = offlineTvs
                          .indexWhere((tv) => tv['id'] == offlineData['film_id']);

                      final List seasons = offlineTvs[tvIndex]['seasons'];

                      final seasonIndex = seasons.indexWhere(
                          (season) => season['id'] == offlineData['season_id']);

                      final List episodes = seasons[seasonIndex]['episodes'];
                      episodes.removeWhere(
                        (episode) => episode['id'] == widget.episodeId,
                      );

                      if (episodes.isEmpty) {
                        seasons.removeAt(seasonIndex);
                        if (seasons.isEmpty) {
                          offlineTvs.removeAt(tvIndex);
                        }
                      }

                      setState(() {
                        downloadState = DownloadState.ready;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xoá tập phim tải xuống'),
                          ),
                        );
                      });
                    },
                  ),
                const SizedBox(width: 16)
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              widget.subtitle,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
