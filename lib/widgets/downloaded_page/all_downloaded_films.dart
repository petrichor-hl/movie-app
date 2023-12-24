// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:movie_app/data/downloaded_film.dart';
// import 'package:movie_app/widgets/downloaded_page/offline_movie.dart';
// import 'package:movie_app/widgets/downloaded_page/offline_tv.dart';

// class AllDownloadedFilm extends StatefulWidget {
//   const AllDownloadedFilm({
//     super.key,
//     required this.onSelectTv,
//     required this.isMultiSelectMode,
//     required this.isSelectAll,
//     required this.unSelectAll,
//     required this.turnOnMultiSelectMode,
//     required this.onSelectItemInMultiMode,
//     required this.unSelectItemInMultiMode,
//   });
//   final void Function(Map<String, dynamic>) onSelectTv;
//   final bool isMultiSelectMode;
//   final bool isSelectAll;
//   final bool unSelectAll;
//   final void Function({required String fromPage}) turnOnMultiSelectMode;
//   final void Function(String filmType, String filmId) onSelectItemInMultiMode;
//   final void Function(String filmType, String filmId) unSelectItemInMultiMode;

//   @override
//   State<AllDownloadedFilm> createState() => _AllDownloadedFilmState();
// }

// class _AllDownloadedFilmState extends State<AllDownloadedFilm> {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 16.0),
//             child: Text(
//               'Phim',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: offlineMovies.length,
//             itemBuilder: (ctx, index) {
//               final movie = offlineMovies[index];
//               final episodeId = movie['seasons'][0]['episodes'][0]['id'];
//               final episodeFile = File('${appDir.path}/episode/$episodeId.mp4');
//               return OfflineMovie(
//                 key: ValueKey(movie['id']),
//                 episodeId: episodeId,
//                 seasonId: movie['seasons'][0]['id'],
//                 filmId: movie['id'],
//                 filmName: movie['film_name'],
//                 posterPath: movie['poster_path'],
//                 runtime: movie['seasons'][0]['episodes'][0]['runtime'],
//                 fileSize: episodeFile.lengthSync(),
//                 isMultiSelectMode: widget.isMultiSelectMode,
//                 isSelectAll: widget.isSelectAll,
//                 unSelectAll: widget.unSelectAll,
//                 turnOnMultiSelectMode: () =>
//                     widget.turnOnMultiSelectMode(fromPage: "all_downloaded_films"),
//                 onSelectItemInMultiMode: () =>
//                     widget.onSelectItemInMultiMode('movie', movie['id']),
//                 unSelectItemInMultiMode: () =>
//                     widget.unSelectItemInMultiMode('movie', movie['id']),
//                 onIndividualDelete: () => setState(() {}),
//               );
//             },
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//           const Padding(
//             padding: EdgeInsets.only(left: 16.0),
//             child: Text(
//               'TV Series',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: offlineTvs.length,
//             itemBuilder: (ctx, index) {
//               final tv = offlineTvs[index];

//               final episodeFolderOfTv = Directory('${appDir.path}/episode/${tv['id']}');

//               int totalSize = 0;
//               final entities = episodeFolderOfTv.listSync();

//               for (final entity in entities) {
//                 final File file = File(entity.path);
//                 totalSize += file.lengthSync();
//               }

//               return OfflineTv(
//                 key: ValueKey(tv['id']),
//                 filmId: tv['id'],
//                 filmName: tv['film_name'],
//                 posterPath: tv['poster_path'],
//                 episodeCount: entities.length,
//                 allEpisodesSize: totalSize,
//                 isMultiSelectMode: widget.isMultiSelectMode,
//                 isSelectAll: widget.isSelectAll,
//                 unSelectAll: widget.unSelectAll,
//                 turnOnMultiSelectMode: () =>
//                     widget.turnOnMultiSelectMode(fromPage: "all_downloaded_films"),
//                 onSelectTv: () => widget.onSelectTv(tv),
//                 onSelectItemInMultiMode: () =>
//                     widget.onSelectItemInMultiMode('tv', tv['id']),
//                 unSelectItemInMultiMode: () =>
//                     widget.unSelectItemInMultiMode('tv', tv['id']),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
