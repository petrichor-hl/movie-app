import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/episode.dart';
import 'package:movie_app/models/offfline_season.dart';
import 'package:movie_app/models/offline_episode.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:path_provider/path_provider.dart';

enum DownloadState {
  ready,
  downloading,
  almostFinished,
  downloaded,
}

class EpisodeUIFirst extends StatefulWidget {
  const EpisodeUIFirst({
    required this.episode,
    required this.isEpisodeDownloaded,
    required this.watchEpisode,
    super.key,
  });

  final Episode episode;
  final bool isEpisodeDownloaded;
  final void Function() watchEpisode;

  @override
  State<EpisodeUIFirst> createState() => _EpisodeUIFristState();
}

class _EpisodeUIFristState extends State<EpisodeUIFirst> {
  late DownloadState downloadState =
      widget.isEpisodeDownloaded ? DownloadState.downloaded : DownloadState.ready;
  double progress = 0;

  final filmInfo = Map.from(offlineData);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: InkWell(
        onTap: () {
          widget.watchEpisode();
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
                    'https://www.themoviedb.org/t/p/w454_and_h254_bestv2/${widget.episode.stillPath}',
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
                          widget.episode.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.episode.runtime} phút',
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
                        widget.episode.linkEpisode,
                        '${appDir.path}/episode/${filmInfo['film_id']}/${widget.episode.episodeId}.mp4',
                        onReceiveProgress: (count, total) {
                          if (mounted) {
                            setState(() {
                              progress = count / total;
                            });
                          }
                        },
                        deleteOnError: true,
                      );

                      // print('added episode_id = ${widget.episode.episodeId}');

                      // 2. download still_path
                      await Dio().download(
                        'https://www.themoviedb.org/t/p/w454_and_h254_bestv2/${widget.episode.stillPath}',
                        '${appDir.path}/still_path/${filmInfo['film_id']}/${widget.episode.stillPath}',
                        deleteOnError: true,
                      );

                      // 3. download film's backdrop_path
                      final posterLocalPath =
                          '${appDir.path}/poster_path/${filmInfo['poster_path']}';
                      final file = File(posterLocalPath);
                      if (!await file.exists()) {
                        await Dio().download(
                          'https://image.tmdb.org/t/p/w440_and_h660_face/${filmInfo['poster_path']}',
                          posterLocalPath,
                          deleteOnError: true,
                        );
                      }

                      // Insert data to local database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      await databaseUtils.insertFilm(filmInfo['film_id'],
                          filmInfo['film_name'], filmInfo['poster_path']);

                      await databaseUtils.insertSeason(
                        id: filmInfo['season_id'],
                        name: filmInfo['season_name'],
                        filmId: filmInfo['film_id'],
                      );

                      await databaseUtils.insertEpisode(
                        id: widget.episode.episodeId,
                        order: widget.episode.order,
                        title: widget.episode.title,
                        runtime: widget.episode.runtime,
                        stillPath: widget.episode.stillPath,
                        seasonId: filmInfo['season_id'],
                      );

                      await databaseUtils.close();

                      // Thêm dữ liệu cho tập phim vừa tải
                      final existingTv = downloadedFilms[filmInfo['film_id']];
                      if (existingTv == null) {
                        downloadedFilms[filmInfo['film_id']] = OfflineFilm(
                          id: filmInfo['film_id'],
                          name: filmInfo['film_name'],
                          posterPath: filmInfo['poster_path'],
                          offlineSeasons: [
                            OfflineSeason(
                              seasonId: filmInfo['season_id'],
                              name: filmInfo['season_name'],
                              offlineEpisodes: [
                                OfflineEpisode(
                                  episodeId: widget.episode.episodeId,
                                  order: widget.episode.order,
                                  title: widget.episode.title,
                                  runtime: widget.episode.runtime,
                                  stillPath: widget.episode.stillPath,
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        final seasons = existingTv.offlineSeasons;
                        final existingIndexSeason = seasons.indexWhere(
                          (season) => season.seasonId == filmInfo['season_id'],
                        );
                        if (existingIndexSeason == -1) {
                          seasons.add(
                            OfflineSeason(
                              seasonId: filmInfo['season_id'],
                              name: filmInfo['season_name'],
                              offlineEpisodes: [
                                OfflineEpisode(
                                  episodeId: widget.episode.episodeId,
                                  order: widget.episode.order,
                                  title: widget.episode.title,
                                  runtime: widget.episode.runtime,
                                  stillPath: widget.episode.stillPath,
                                ),
                              ],
                            ),
                          );
                        } else {
                          final existingSeason = seasons[existingIndexSeason];
                          existingSeason.offlineEpisodes.add(
                            OfflineEpisode(
                              episodeId: widget.episode.episodeId,
                              order: widget.episode.order,
                              title: widget.episode.title,
                              runtime: widget.episode.runtime,
                              stillPath: widget.episode.stillPath,
                            ),
                          );
                        }
                      }

                      if (mounted) {
                        setState(() {
                          downloadState = DownloadState.downloaded;
                        });
                      }
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
                    icon: const Icon(
                      Icons.download_done,
                      color: Colors.white,
                    ),
                    iconSize: 28,
                    tooltip: '',
                    onSelected: (_) async {
                      final episodeFile = File(
                          '${appDir.path}/episode/${filmInfo['film_id']}/${widget.episode.episodeId}.mp4');
                      await episodeFile.delete();

                      final stillPathFile = File(
                          '${appDir.path}/still_path/${filmInfo['film_id']}/${widget.episode.stillPath}');
                      await stillPathFile.delete();

                      // Xoá dữ liệu trong Database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();

                      await databaseUtils.deleteEpisode(
                        id: widget.episode.episodeId,
                        seasonId: filmInfo['season_id'],
                        filmId: filmInfo['film_id'],
                        clean: () async {
                          final posterFile = File(
                              '${appDir.path}/poster_path/${filmInfo['poster_path']}');
                          await posterFile.delete();

                          final episodeTvDir =
                              Directory('${appDir.path}/episode/${filmInfo['film_id']}');
                          await episodeTvDir.delete();

                          final stillPathDir = Directory(
                              '${appDir.path}/still_path/${filmInfo['film_id']}');
                          await stillPathDir.delete();
                        },
                      );
                      await databaseUtils.close();

                      // Xoá dữ liệu trong app's memory
                      final tv = downloadedFilms[filmInfo['film_id']]!;
                      final seasons = tv.offlineSeasons;
                      final seasonIndex = seasons.indexWhere(
                        (season) => season.seasonId == filmInfo['season_id'],
                      );
                      final episodes = seasons[seasonIndex].offlineEpisodes;
                      episodes.removeWhere(
                        (episode) => episode.episodeId == widget.episode.episodeId,
                      );
                      if (episodes.isEmpty) {
                        seasons.removeAt(seasonIndex);
                        if (seasons.isEmpty) {
                          downloadedFilms.remove(filmInfo['film_id']);
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
              widget.episode.subtitle,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
