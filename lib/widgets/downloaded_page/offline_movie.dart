import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/screens/main/downloaded.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';

class OfflineMovie extends StatefulWidget {
  const OfflineMovie({
    super.key,
    required this.episodeId,
    required this.seasonId,
    required this.filmId,
    required this.filmName,
    required this.posterPath,
    required this.runtime,
    required this.fileSize,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.onMultiSelect,
    required this.unMultiSelect,
    required this.onIndividualDelete,
  });

  final String episodeId;
  final String seasonId;
  final String filmId;
  final String filmName;
  final String posterPath;
  final int runtime;
  final int fileSize;
  final bool isMultiSelectMode;
  final void Function() turnOnMultiSelectMode;
  final void Function() onMultiSelect;
  final void Function() unMultiSelect;
  final void Function() onIndividualDelete;

  @override
  State<OfflineMovie> createState() => _OfflineMovieState();
}

class _OfflineMovieState extends State<OfflineMovie> {
  bool _isChecked = false;

  @override
  void didUpdateWidget(covariant OfflineMovie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMultiSelectMode == false) {
      _isChecked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.isMultiSelectMode
          ? () {
              setState(() {
                _isChecked = !_isChecked;
                _isChecked ? widget.onMultiSelect() : widget.unMultiSelect();
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
                      title: widget.filmName,
                      videoLink: '${appDir.path}/episode/${widget.episodeId}.mp4',
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
          _isChecked ? widget.onMultiSelect() : widget.unMultiSelect();
        });
      },
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File('${appDir.path}/poster_path/${widget.posterPath}'),
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
                  widget.filmName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.runtime} phút',
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
                // Delete Movie
                // print('remove film: $filmName');

                final episodeFile =
                    File('${appDir.path}/episode/${widget.episodeId}.mp4');
                await episodeFile.delete();

                final databaseUtils = DatabaseUtils();
                await databaseUtils.connect();
                await databaseUtils.deleteEpisode(
                  id: widget.episodeId,
                  seasonId: widget.seasonId,
                  filmId: widget.filmId,
                  deletePosterPath: () async {
                    final posterFile =
                        File('${appDir.path}/poster_path/${widget.posterPath}');
                    await posterFile.delete();
                  },
                );
                await databaseUtils.close();

                episodeIds.remove(widget.episodeId);

                final index =
                    offlineMovies.indexWhere((movie) => movie['id'] == widget.filmId);
                offlineMovies.removeAt(index);
                widget.onIndividualDelete();
              },
            ),
    );
  }
}
