import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';
import 'package:path_provider/path_provider.dart';

enum DownloadState {
  ready,
  downloading,
  downloaded,
}

class Episode extends StatefulWidget {
  const Episode(
    this.episodeId,
    this.stillPath,
    this.title,
    this.runtime,
    this.subtitle,
    this.linkEpisode, {
    super.key,
  });

  final String episodeId;
  final String stillPath;
  final String title;
  final int runtime;
  final String subtitle;
  final String linkEpisode;

  @override
  State<Episode> createState() => _EpisodeState();
}

class _EpisodeState extends State<Episode> {
  var downloadState = DownloadState.ready;
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
                child: VideoPlayerView(
                  title: widget.title,
                  episodeUrl: widget.linkEpisode,
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
                      print('download to: $appDir');
                      await Dio().download(
                        widget.linkEpisode,
                        '${appDir.path}/${widget.episodeId}.mp4',
                        onReceiveProgress: (count, total) {
                          setState(() {
                            progress = count / total;
                          });
                        },
                        deleteOnError: true,
                      );

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
                          child: Text('Xoá tệp tải xuống'),
                        ),
                      ];
                    },
                    icon: const Icon(Icons.download_done),
                    iconSize: 28,
                    color: Colors.white,
                    tooltip: '',
                    onSelected: (_) async {
                      final appDir = await getApplicationDocumentsDirectory();
                      final file =
                          File('${appDir.path}/${widget.episodeId}.mp4');
                      if (await file.exists()) {
                        await file.delete();
                        setState(() {
                          downloadState = DownloadState.ready;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xoá tập phim tải xuống'),
                            ),
                          );
                        });
                      }
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
