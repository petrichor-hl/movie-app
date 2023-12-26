import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:movie_app/widgets/downloaded_page/downloaded_episode.dart';
import 'package:movie_app/widgets/video_player_offline/video_player_offline_view.dart';

class AllDownloadedEpisodesOfTV extends StatefulWidget {
  const AllDownloadedEpisodesOfTV({
    super.key,
    required this.offlineTv,
  });

  final OfflineFilm offlineTv;

  @override
  State<AllDownloadedEpisodesOfTV> createState() => _AllDownloadedEpisodesOfTVState();
}

class _AllDownloadedEpisodesOfTVState extends State<AllDownloadedEpisodesOfTV> {
  bool _isMultiSelectMode = false;

  // Lưu id của các Tập phim được chọn trong Multi Select Mode
  final _selectedEpisodes = <String>[];

  @override
  Widget build(BuildContext context) {
    final filmId = widget.offlineTv.id;
    final filmName = widget.offlineTv.name;
    final seasons = widget.offlineTv.offlineSeasons;
    return Scaffold(
      appBar: AppBar(
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedEpisodes.clear();
                  });
                },
                icon: const Icon(Icons.cancel),
                padding: const EdgeInsets.all(16),
              ).animate().scale()
            : null,
        title: Text(
          filmName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _isMultiSelectMode
            ? [
                IconButton(
                  onPressed: () async {
                    for (final selectedEpisode in _selectedEpisodes) {
                      final parts = selectedEpisode.split('/');
                      final seasonId = parts[0];
                      final episodeId = parts[1];
                      final stillPath = parts[2];
                      // Xoá trong Application Directory
                      final episodeFile = File(
                          '${appDir.path}/episode/${widget.offlineTv.id}/$episodeId.mp4');
                      await episodeFile.delete();
                      //
                      final stillPathFile = File(
                          '${appDir.path}/still_path/${widget.offlineTv.id}/$stillPath');
                      await stillPathFile.delete();

                      // Xoá dữ liệu trong Database
                      final databaseUtils = DatabaseUtils();
                      await databaseUtils.connect();

                      await databaseUtils.deleteEpisode(
                        id: episodeId,
                        seasonId: seasonId,
                        filmId: widget.offlineTv.id,
                        clean: () async {
                          final posterFile = File(
                              '${appDir.path}/poster_path/${widget.offlineTv.posterPath}');
                          await posterFile.delete();

                          final episodeTvDir =
                              Directory('${appDir.path}/episode/${widget.offlineTv.id}');
                          await episodeTvDir.delete();

                          final stillPathDir = Directory(
                              '${appDir.path}/still_path/${widget.offlineTv.id}');
                          await stillPathDir.delete();
                        },
                      );
                      await databaseUtils.close();

                      // Xoá dữ liệu trong app's memory
                      final downloadedTv = downloadedFilms[widget.offlineTv.id]!;

                      final seasons = downloadedTv.offlineSeasons;
                      final seasonIndex = seasons.indexWhere(
                        (season) => season.seasonId == seasonId,
                      );

                      final episodes = seasons[seasonIndex].offlineEpisodes;

                      episodes.removeWhere(
                        (episode) => episode.episodeId == episodeId,
                      );

                      if (episodes.isEmpty) {
                        seasons.removeAt(seasonIndex);
                        if (seasons.isEmpty) {
                          downloadedFilms.remove(widget.offlineTv.id);
                          if (mounted) {
                            Navigator.of(context).pop('reload_downloaded_page');
                          }
                        }
                      }
                    }

                    setState(() {
                      _selectedEpisodes.clear();
                      _isMultiSelectMode = false;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xoá các tệp phim'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_rounded),
                  padding: const EdgeInsets.all(16),
                ).animate().scale()
              ]
            : null,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: List.generate(
          seasons.length,
          (seasonIndex) {
            final season = seasons[seasonIndex];
            final episodes = season.offlineEpisodes;
            episodes.sort(
              (a, b) => (a.order).compareTo(b.order),
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    season.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  itemBuilder: (ctx, episodeIndex) {
                    final episodeFile = File(
                      '${appDir.path}/episode/$filmId/${episodes[episodeIndex].episodeId}.mp4',
                    );

                    return DownloadedEpisode(
                      offlineEpisode: episodes[episodeIndex],
                      fileSize: episodeFile.lengthSync(),
                      /*
                      Truyền filmId, posterPath, seasonId sẽ có tác dụng khi cần xoá những tệp đã tải
                      */
                      filmId: filmId,
                      posterPath: widget.offlineTv.posterPath,
                      seasonId: season.seasonId,
                      isMultiSelectMode: _isMultiSelectMode,
                      turnOnMultiSelectMode: () => setState(() {
                        _isMultiSelectMode = true;
                      }),
                      onSelectItemInMultiMode: () => _selectedEpisodes.add(
                          '${season.seasonId}/${episodes[episodeIndex].episodeId}/${episodes[episodeIndex].stillPath}'),
                      unSelectItemInMultiMode: () => _selectedEpisodes.remove(
                          '${season.seasonId}/${episodes[episodeIndex].episodeId}/${episodes[episodeIndex].stillPath}'),
                      onIndividualDelete: () => setState(() {}),
                      watchEpisode: () {
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
                                filmId: filmId,
                                seasons: seasons,
                                firstEpisodeToPlay: episodes[episodeIndex],
                                firstSeasonIndex: seasonIndex,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
