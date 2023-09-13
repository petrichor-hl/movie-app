import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/screens/main/downloaded.dart';

class OfflineTv extends StatelessWidget {
  const OfflineTv({
    super.key,
    required this.filmId,
    required this.filmName,
    required this.posterPath,
    required this.episodeCount,
    required this.allEpisodesSize,
    required this.onSelectTv,
  });
  final String filmId;
  final String filmName;
  final String posterPath;
  final int episodeCount;
  final int allEpisodesSize;
  final void Function() onSelectTv;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onSelectTv,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File('${appDir.path}/poster_path/$posterPath'),
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
                  filmName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$episodeCount tập',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  formatBytes(allEpisodesSize),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: const SizedBox(
        width: 48,
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
        ),
      ),
    );
  }
}
