// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:movie_app/data/downloaded_film.dart';
// import 'package:movie_app/widgets/downloaded_page/downloaded_episode.dart';

// class AllDownloadedEpisode extends StatefulWidget {
//   const AllDownloadedEpisode(
//     this.selectedTv, {
//     super.key,
//     required this.backToAllDownloadedFilm,
//     required this.isMultiSelectMode,
//     required this.turnOnMultiSelectMode,
//     required this.onSelectItemInMultiMode,
//     required this.unSelectItemInMultiMode,
//   });

//   final Map<String, dynamic> selectedTv;
//   final void Function() backToAllDownloadedFilm;
//   final bool isMultiSelectMode;
//   final void Function({required String fromPage}) turnOnMultiSelectMode;
//   final void Function(String filmType, String episodeId) onSelectItemInMultiMode;
//   final void Function(String filmType, String episodeId) unSelectItemInMultiMode;

//   @override
//   State<AllDownloadedEpisode> createState() => _AllDownloadedEpisodeState();
// }

// class _AllDownloadedEpisodeState extends State<AllDownloadedEpisode> {
//   @override
//   Widget build(BuildContext context) {
//     final List<dynamic> seasons = widget.selectedTv['seasons'] ?? [];

//     return Scaffold(
//       body: SizedBox.expand(
//         child: widget.selectedTv.isEmpty
//             ? null
//             : ListView(
//                 children: List.generate(seasons.length, (index) {
//                   final season = seasons[index];
//                   final List<Map<String, dynamic>> episodes = season['episodes'];
//                   episodes.sort(
//                     (a, b) => (a['order'] as int).compareTo(b['order']),
//                   );
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8),
//                         child: Text(
//                           season['season_name'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: episodes.length,
//                         itemBuilder: (ctx, index) {
//                           final episodeFile = File(
//                             '${appDir.path}/episode/${widget.selectedTv['id']}/${episodes[index]['id']}.mp4',
//                           );

//                           return DownloadedEpisode(
//                             episodeId: episodes[index]['id'],
//                             title: episodes[index]['title'],
//                             order: episodes[index]['order'],
//                             stillPath: episodes[index]['still_path'],
//                             runtime: episodes[index]['runtime'],
//                             fileSize: episodeFile.lengthSync(),
//                             seasonId: season['id'],
//                             filmId: widget.selectedTv['id'],
//                             posterPath: widget.selectedTv['poster_path'],
//                             onDeleteSeason: () => setState(() {}),
//                             backToAllDownloadedFilm: widget.backToAllDownloadedFilm,
//                             onIndividualDelete: () => setState(() {}),
//                             isMultiSelectMode: widget.isMultiSelectMode,
//                             turnOnMultiSelectMode: () => widget.turnOnMultiSelectMode(
//                               fromPage: "all_downloaded_episodes",
//                             ),
//                             onSelectItemInMultiMode: () => widget.onSelectItemInMultiMode(
//                                 'episode', season['id'] + '/' + episodes[index]['id']),
//                             unSelectItemInMultiMode: () => widget.unSelectItemInMultiMode(
//                                 'episode', season['id'] + '/' + episodes[index]['id']),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:movie_app/widgets/downloaded_page/downloaded_episode.dart';

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
          (index) {
            final season = seasons[index];
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
                  itemBuilder: (ctx, index) {
                    final episodeFile = File(
                      '${appDir.path}/episode/$filmId/${episodes[index].episodeId}.mp4',
                    );

                    return DownloadedEpisode(
                      offlineEpisode: episodes[index],
                      fileSize: episodeFile.lengthSync(),
                      seasonId: season.seasonId,
                      filmId: filmId,
                      posterPath: widget.offlineTv.posterPath,
                      isMultiSelectMode: _isMultiSelectMode,
                      turnOnMultiSelectMode: () => setState(() {
                        _isMultiSelectMode = true;
                      }),
                      onSelectItemInMultiMode: () => _selectedEpisodes.add(
                          '${season.seasonId}/${episodes[index].episodeId}/${episodes[index].stillPath}'),
                      unSelectItemInMultiMode: () => _selectedEpisodes.remove(
                          '${season.seasonId}/${episodes[index].episodeId}/${episodes[index].stillPath}'),
                      onIndividualDelete: () => setState(() {}),
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
