import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/models/offline_episode.dart';

class DownloadedEpisodeUISecond extends StatefulWidget {
  const DownloadedEpisodeUISecond({
    super.key,
    required this.filmId,
    required this.offlineEpisode,
    required this.seasonIndex,
    required this.isEpisodeDownloaded,
  });

  final String filmId;
  final OfflineEpisode offlineEpisode;
  // seasonIndex là số thứ tự season chứa tập phim này
  final int seasonIndex;
  final bool isEpisodeDownloaded;

  @override
  State<DownloadedEpisodeUISecond> createState() => _DownloadedEpisodeUISecondState();
}

class _DownloadedEpisodeUISecondState extends State<DownloadedEpisodeUISecond> {
  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.only(right: 10),
      width: 227,
      child: Column(
        children: [
          Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF333333),
              image: DecorationImage(
                image: FileImage(
                  File(
                    '${appDir.path}/still_path/${widget.filmId}/${widget.offlineEpisode.stillPath}',
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
            height: 127,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(
                  {
                    'episode': widget.offlineEpisode,
                    // seasonIndex là số thứ tự season chứa tập phim này
                    'season_index': widget.seasonIndex,
                  },
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Gap(6),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.offlineEpisode.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(10),
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.download),
              )
            ],
          ),
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
