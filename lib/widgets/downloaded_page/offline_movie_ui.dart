import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:movie_app/utils/extension.dart';
import 'package:movie_app/widgets/video_player_offline/video_player_offline_view.dart';

class OfflineMovieUI extends StatefulWidget {
  const OfflineMovieUI({
    super.key,
    required this.offlineMovie,
    required this.fileSize,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.onSelectItemInMultiMode,
    required this.unSelectItemInMultiMode,
    required this.onIndividualDelete,
  });

  final OfflineFilm offlineMovie;
  final int fileSize;
  //
  final bool isMultiSelectMode;
  final void Function() turnOnMultiSelectMode;
  final void Function() onSelectItemInMultiMode;
  final void Function() unSelectItemInMultiMode;
  //
  final void Function() onIndividualDelete;

  @override
  State<OfflineMovieUI> createState() => _OfflineMovieUIState();
}

class _OfflineMovieUIState extends State<OfflineMovieUI> {
  bool _isChecked = false;

  @override
  void didUpdateWidget(covariant OfflineMovieUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMultiSelectMode == false) {
      _isChecked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final season = widget.offlineMovie.offlineSeasons[0];
    final episode = season.offlineEpisodes[0];

    return ListTile(
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
                    child: VideoPlayerOfflineView(
                      filmId: widget.offlineMovie.id,
                      seasons: widget.offlineMovie.offlineSeasons,
                      firstEpisodeToPlay:
                          widget.offlineMovie.offlineSeasons[0].offlineEpisodes[0],
                      firstSeasonIndex: 0,
                    ),
                  ),
                ),
              );
            },
      onLongPress: () {
        widget.turnOnMultiSelectMode();
        _isChecked = true;
        widget.onSelectItemInMultiMode();
      },
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File('${appDir.path}/poster_path/${widget.offlineMovie.posterPath}'),
              height: 150,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offlineMovie.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${episode.runtime} phút',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  formatBytes(widget.fileSize),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: widget.isMultiSelectMode
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
              icon: const Icon(
                Icons.download_done,
                color: Colors.white,
              ),
              iconSize: 28,
              tooltip: '',
              onSelected: (_) async {
                // Delete Movie
                // print('remove film: $filmName');

                final episodeFile =
                    File('${appDir.path}/episode/${episode.episodeId}.mp4');
                await episodeFile.delete();

                final databaseUtils = DatabaseUtils();
                await databaseUtils.connect();
                await databaseUtils.deleteEpisode(
                  id: episode.episodeId,
                  seasonId: season.seasonId,
                  filmId: widget.offlineMovie.id,
                  clean: () async {
                    final posterFile = File(
                        '${appDir.path}/poster_path/${widget.offlineMovie.posterPath}');
                    await posterFile.delete();
                  },
                );
                await databaseUtils.close();

                widget.onIndividualDelete();

                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xoá tệp phim'),
                    ),
                  );
                }
                // or
                // Timer(Duration.zero, () {
                //   ScaffoldMessenger.of(context).clearSnackBars();
                //   ScaffoldMessenger.of(context)
                //       .showSnackBar(const SnackBar(content: Text('Đã xoá tập phim')));
                // });
              },
            ),
    );
  }
}
