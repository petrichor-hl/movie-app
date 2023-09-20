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

class DownloadedEpisode extends StatefulWidget {
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
    required this.backToAllDownloadedFilm,
    required this.onIndividualDelete,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.onSelectItemInMultiMode,
    required this.unSelectItemInMultiMode,
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
  final void Function() onIndividualDelete;
  final bool isMultiSelectMode;
  final void Function() turnOnMultiSelectMode;
  final void Function() onSelectItemInMultiMode;
  final void Function() unSelectItemInMultiMode;

  @override
  State<DownloadedEpisode> createState() => _DownloadedEpisodeState();
}

class _DownloadedEpisodeState extends State<DownloadedEpisode> {
  bool _isChecked = false;

  @override
  void didUpdateWidget(covariant DownloadedEpisode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMultiSelectMode == false) {
      _isChecked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isMultiSelectMode
          ? () {
              setState(() {
                _isChecked = !_isChecked;
                _isChecked
                    ? widget.onSelectItemInMultiMode()
                    : widget.unSelectItemInMultiMode();
              });
            }
          : () {
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
                      videoLink:
                          '${appDir.path}/episode/${widget.filmId}/${widget.episodeId}.mp4',
                      videoLocation: 'local',
                    ),
                  ),
                ),
              );
            },
      onLongPress: () {
        widget.turnOnMultiSelectMode();
        setState(() {
          _isChecked = true;
          _isChecked
              ? widget.onSelectItemInMultiMode()
              : widget.unSelectItemInMultiMode();
        });
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
                      '${appDir.path}/still_path/${widget.filmId}/${widget.stillPath}',
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
                      widget.order.toString(),
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
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.runtime} phút | ${formatBytes(widget.fileSize)}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            widget.isMultiSelectMode
                ? Checkbox(
                    value: _isChecked,
                    onChanged: (value) => setState(() {
                      if (value != null) {
                        _isChecked = value;
                        _isChecked
                            ? widget.onSelectItemInMultiMode()
                            : widget.unSelectItemInMultiMode();
                      }
                    }),
                  )
                : PopupMenuButton(
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
                          '${appDir.path}/episode/${widget.filmId}/${widget.episodeId}.mp4');
                      await episodeFile.delete();

                      final stillPathFile = File(
                          '${appDir.path}/still_path/${widget.filmId}/${widget.stillPath}');
                      await stillPathFile.delete();

                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();
                      await databaseUtils.deleteEpisode(
                        id: widget.episodeId,
                        seasonId: widget.seasonId,
                        filmId: widget.filmId,
                        clean: () async {
                          final posterFile =
                              File('${appDir.path}/poster_path/${widget.posterPath}');
                          await posterFile.delete();

                          final episodeTvDir =
                              Directory('${appDir.path}/episode/${widget.filmId}');
                          await episodeTvDir.delete();

                          final stillPathDir =
                              Directory('${appDir.path}/still_path/${widget.filmId}');
                          await stillPathDir.delete();
                        },
                      );
                      await databaseUtils.close();

                      downloadedEpisodeId.remove(widget.episodeId);

                      // remove data in offlineTvs
                      final tvIndex = offlineTvs.indexWhere(
                        (tv) => tv['id'] == widget.filmId,
                      );

                      final List seasons = offlineTvs[tvIndex]['seasons'];
                      final seasonIndex = seasons.indexWhere(
                        (season) => season['id'] == widget.seasonId,
                      );

                      final List episodes = seasons[seasonIndex]['episodes'];

                      episodes.removeWhere(
                        (episode) => episode['id'] == widget.episodeId,
                      );

                      widget.onIndividualDelete();

                      if (episodes.isEmpty) {
                        seasons.removeAt(seasonIndex);
                        widget.onDeleteSeason();
                        if (seasons.isEmpty) {
                          offlineTvs.removeAt(tvIndex);
                          widget.backToAllDownloadedFilm();
                        }
                      }
                      Timer(Duration.zero, () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xoá tập phim')));
                      });
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
