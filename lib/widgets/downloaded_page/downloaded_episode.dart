import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/offline_episode.dart';
import 'package:movie_app/utils/extension.dart';

class DownloadedEpisode extends StatefulWidget {
  const DownloadedEpisode({
    super.key,
    required this.offlineEpisode,
    required this.fileSize,
    required this.filmId,
    required this.posterPath,
    required this.seasonId,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.onSelectItemInMultiMode,
    required this.unSelectItemInMultiMode,
    required this.onIndividualDelete,
    required this.watchEpisode,
  });

  final OfflineEpisode offlineEpisode;
  final int fileSize;

  /*
  Truyền filmId, posterPath, seasonId sẽ có tác dụng khi cần xoá những tệp đã tải
  */
  final String filmId;
  final String posterPath;
  final String seasonId;

  //
  final bool isMultiSelectMode;
  final void Function() turnOnMultiSelectMode;
  final void Function() onSelectItemInMultiMode;
  final void Function() unSelectItemInMultiMode;
  //
  final void Function() onIndividualDelete;
  //
  final void Function() watchEpisode;

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
              widget.watchEpisode();
            },
      onLongPress: () {
        widget.turnOnMultiSelectMode();
        _isChecked = true;
        widget.onSelectItemInMultiMode();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Ink(
              height: 95,
              width: 170,
              padding: _isChecked ? const EdgeInsets.symmetric(vertical: 10) : null,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Image.file(
                        File(
                          '${appDir.path}/still_path/${widget.filmId}/${widget.offlineEpisode.stillPath}',
                        ),
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
                          widget.offlineEpisode.order.toString(),
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offlineEpisode.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.offlineEpisode.runtime} phút | ${formatBytes(widget.fileSize)}',
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
                    icon: const Icon(
                      Icons.download_done,
                      color: Colors.white,
                    ),
                    iconSize: 28,
                    tooltip: '',
                    onSelected: (_) async {
                      final episodeFile = File(
                          '${appDir.path}/episode/${widget.filmId}/${widget.offlineEpisode.episodeId}.mp4');
                      await episodeFile.delete();

                      final stillPathFile = File(
                          '${appDir.path}/still_path/${widget.filmId}/${widget.offlineEpisode.stillPath}');
                      await stillPathFile.delete();

                      // Xoá dữ liệu trong Database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();

                      await databaseUtils.deleteEpisode(
                        id: widget.offlineEpisode.episodeId,
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

                      // Xoá dữ liệu trong app's memory
                      final downloadedTv = downloadedFilms[widget.filmId]!;

                      final seasons = downloadedTv.offlineSeasons;
                      final seasonIndex = seasons.indexWhere(
                        (season) => season.seasonId == widget.seasonId,
                      );

                      final episodes = seasons[seasonIndex].offlineEpisodes;

                      episodes.removeWhere(
                        (episode) => episode.episodeId == widget.offlineEpisode.episodeId,
                      );

                      widget.onIndividualDelete();

                      if (episodes.isEmpty) {
                        seasons.removeAt(seasonIndex);
                        if (seasons.isEmpty) {
                          downloadedFilms.remove(widget.filmId);
                          if (mounted) {
                            Navigator.of(context).pop('reload_downloaded_page');
                          }
                        }
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xoá tệp phim'),
                          ),
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
