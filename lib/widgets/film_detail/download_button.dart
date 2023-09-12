import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_episode.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/widgets/film_detail/episode.dart';
import 'package:path_provider/path_provider.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.firstEpisodeLink,
    required this.firstEpisodeId,
    required this.runtime,
  });

  final String firstEpisodeLink;
  final String firstEpisodeId;
  final int runtime;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  late final widthButton = MediaQuery.sizeOf(context).width;
  double progress = 0;

  late DownloadState downloadState = episodeIds.contains(widget.firstEpisodeId)
      ? DownloadState.downloaded
      : DownloadState.ready;

  @override
  Widget build(BuildContext context) {
    return downloadState == DownloadState.downloaded
        ? SizedBox(
            height: 40,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        MenuItemButton(
                          trailingIcon: const Icon(Icons.delete),
                          child: const Text('Xoá tệp tải xuống'),
                          onPressed: () async {
                            final episodeFile = File(
                                '${appDir.path}/episode/${widget.firstEpisodeId}.mp4');
                            await episodeFile.delete();

                            final databaseUtils = DatabaseUtils();
                            await databaseUtils.connect();
                            await databaseUtils.deleteEpisode(
                              id: widget.firstEpisodeId,
                              seasonId: offlineData['season_id'],
                              filmId: offlineData['film_id'],
                              deletePosterPath: () async {
                                final posterFile = File(
                                    '${appDir.path}/poster_path/${offlineData['poster_path']}');
                                await posterFile.delete();
                              },
                            );
                            await databaseUtils.close();

                            episodeIds.remove(widget.firstEpisodeId);

                            setState(() {
                              downloadState = DownloadState.ready;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xoá tập phim tải xuống'),
                                ),
                              );
                            });
                          },
                        ),
                        MenuItemButton(
                          trailingIcon: const Icon(Icons.download_for_offline),
                          child: const Text('Xem Nội dung tải xuống của tôi'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.download_done),
              label: const Text(
                'Đã tải xuống',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(36, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )
        : InkWell(
            onTap: downloadState == DownloadState.ready
                ? () async {
                    setState(() {
                      downloadState = DownloadState.downloading;
                    });

                    final appDir = await getApplicationDocumentsDirectory();
                    // print('download to: $appDir');

                    // 1. download video
                    await Dio().download(
                      widget.firstEpisodeLink,
                      '${appDir.path}/episode/${widget.firstEpisodeId}.mp4',
                      onReceiveProgress: (count, total) {
                        setState(() {
                          progress = count / total;
                        });
                      },
                      deleteOnError: true,
                    );

                    // 2. download film's poster_path
                    final backdropLocalPath =
                        '${appDir.path}/poster_path/${offlineData['poster_path']}';
                    final file = File(backdropLocalPath);
                    if (!await file.exists()) {
                      await Dio().download(
                        'https://image.tmdb.org/t/p/w440_and_h660_face/${offlineData['poster_path']}',
                        backdropLocalPath,
                        deleteOnError: true,
                      );
                    }

                    // Insert data to local database
                    final databaseUtils = DatabaseUtils();
                    await databaseUtils.connect();
                    await databaseUtils.insertFilm(
                      offlineData['film_id'],
                      offlineData['film_name'],
                      offlineData['poster_path'],
                    );

                    await databaseUtils.insertSeason(
                      id: offlineData['season_id'],
                      filmId: offlineData['film_id'],
                    );

                    await databaseUtils.insertEpisode(
                      id: widget.firstEpisodeId,
                      runtime: widget.runtime,
                      seasonId: offlineData['season_id'],
                    );

                    await databaseUtils.close();

                    episodeIds.add(widget.firstEpisodeId);
                    offlineMovies.add({
                      'id': offlineData['film_id'],
                      'film_name': offlineData['film_name'],
                      'poster_path': offlineData['poster_path'],
                      'seasons': [
                        {
                          'id': offlineData['season_id'],
                          'episodes': [
                            {
                              'id': widget.firstEpisodeId,
                              'runtime': widget.runtime,
                            }
                          ]
                        }
                      ]
                    });

                    setState(() {
                      downloadState = DownloadState.downloaded;
                      progress = 0;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color.fromARGB(36, 255, 255, 255),
                  ),
                  width: double.infinity,
                  height: 40,
                ),
                if (downloadState == DownloadState.downloading)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.amber,
                      ),
                      width: widthButton * progress,
                    ),
                  ),
                if (downloadState == DownloadState.ready)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tải xuống',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                if (downloadState == DownloadState.downloading)
                  Text(
                    'Đang tải ... ${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          );
  }
}
