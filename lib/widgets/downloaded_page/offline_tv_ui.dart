// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:movie_app/data/downloaded_film.dart';
// import 'package:movie_app/screens/main/downloaded.dart';

// class OfflineTv extends StatefulWidget {
//   const OfflineTv({
//     super.key,
//     required this.filmId,
//     required this.filmName,
//     required this.posterPath,
//     required this.episodeCount,
//     required this.allEpisodesSize,
//     required this.isMultiSelectMode,
//     required this.isSelectAll,
//     required this.unSelectAll,
//     required this.turnOnMultiSelectMode,
//     required this.onSelectTv,
//     required this.onSelectItemInMultiMode,
//     required this.unSelectItemInMultiMode,
//   });

//   final String filmId;
//   final String filmName;
//   final String posterPath;
//   final int episodeCount;
//   final int allEpisodesSize;
//   final bool isMultiSelectMode;
//   final bool isSelectAll;
//   final bool unSelectAll;
//   final void Function() turnOnMultiSelectMode;
//   final void Function() onSelectTv;
//   final void Function() onSelectItemInMultiMode;
//   final void Function() unSelectItemInMultiMode;

//   @override
//   State<OfflineTv> createState() => _OfflineTvState();
// }

// class _OfflineTvState extends State<OfflineTv> {
//   bool _isChecked = false;

//   @override
//   void didUpdateWidget(covariant OfflineTv oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isMultiSelectMode == false) {
//       _isChecked = false;
//     } else {
//       if (widget.isSelectAll) {
//         _isChecked = true;
//       } else {
//         if (widget.unSelectAll) {
//           _isChecked = false;
//         }
//         _isChecked = _isChecked || widget.isSelectAll;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: widget.isMultiSelectMode
//           ? () {
//               setState(() {
//                 _isChecked = !_isChecked;
//                 _isChecked
//                     ? widget.onSelectItemInMultiMode()
//                     : widget.unSelectItemInMultiMode();
//               });
//             }
//           : widget.onSelectTv,
//       onLongPress: () {
//         widget.turnOnMultiSelectMode();
//         setState(() {
//           _isChecked = true;
//           _isChecked
//               ? widget.onSelectItemInMultiMode()
//               : widget.unSelectItemInMultiMode();
//         });
//       },
//       title: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               File('${appDir.path}/poster_path/${widget.posterPath}'),
//               height: 150,
//             ),
//           ),
//           const SizedBox(
//             width: 20,
//           ),
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.filmName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${widget.episodeCount} tập',
//                   style: const TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//                 Text(
//                   formatBytes(widget.allEpisodesSize),
//                   style: const TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       trailing: widget.isMultiSelectMode
//           ? Checkbox(
//               value: _isChecked,
//               onChanged: (value) => setState(() {
//                 if (value != null) {
//                   _isChecked = value;
//                   _isChecked
//                       ? widget.onSelectItemInMultiMode()
//                       : widget.unSelectItemInMultiMode();
//                 }
//               }),
//             )
//           : const SizedBox(
//               width: 48,
//               child: Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//               ),
//             ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/models/offline_film.dart';
import 'package:movie_app/utils/extension.dart';
import 'package:movie_app/widgets/downloaded_page/all_downloaded_episodes.dart';
import 'package:page_transition/page_transition.dart';

class OfflineTvUI extends StatefulWidget {
  const OfflineTvUI({
    super.key,
    required this.offlineTv,
    required this.episodeCount,
    required this.allEpisodesSize,
    required this.isMultiSelectMode,
    required this.turnOnMultiSelectMode,
    required this.onSelectItemInMultiMode,
    required this.unSelectItemInMultiMode,
    required this.reloadDownloadedPage,
  });

  final OfflineFilm offlineTv;
  final int episodeCount;
  final int allEpisodesSize;
  //
  final bool isMultiSelectMode;
  final void Function() turnOnMultiSelectMode;
  final void Function() onSelectItemInMultiMode;
  final void Function() unSelectItemInMultiMode;
  //
  final void Function() reloadDownloadedPage;

  @override
  State<OfflineTvUI> createState() => _OfflineTvUIState();
}

class _OfflineTvUIState extends State<OfflineTvUI> {
  bool _isChecked = false;

  @override
  void didUpdateWidget(covariant OfflineTvUI oldWidget) {
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
                _isChecked
                    ? widget.onSelectItemInMultiMode()
                    : widget.unSelectItemInMultiMode();
              });
            }
          : () async {
              final String? message = await Navigator.of(context).push(
                PageTransition(
                  child: AllDownloadedEpisodesOfTV(
                    offlineTv: widget.offlineTv,
                  ),
                  type: PageTransitionType.rightToLeft,
                  settings: const RouteSettings(name: '/bottom_nav'),
                ),
              );
              if (message == 'reload_downloaded_page') {
                widget.reloadDownloadedPage();
              }
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
              File('${appDir.path}/poster_path/${widget.offlineTv.posterPath}'),
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
                  widget.offlineTv.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.episodeCount} tập',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  formatBytes(widget.allEpisodesSize),
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
          : const SizedBox(
              width: 48,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ),
    );
  }
}
