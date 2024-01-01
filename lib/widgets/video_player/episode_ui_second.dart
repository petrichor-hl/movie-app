import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/models/episode.dart';

class EpisodeUISecond extends StatefulWidget {
  const EpisodeUISecond({
    super.key,
    required this.episode,
    required this.seasonIndex,
    required this.isEpisodeDownloaded,
  });

  final Episode episode;
  // seasonIndex là số thứ tự season chứa tập phim này
  final int seasonIndex;
  final bool isEpisodeDownloaded;

  @override
  State<EpisodeUISecond> createState() => _EpisodeUISecondState();
}

class _EpisodeUISecondState extends State<EpisodeUISecond> {
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
                image: CachedNetworkImageProvider(
                  'https://www.themoviedb.org/t/p/w454_and_h254_bestv2/${widget.episode.stillPath}',
                ),
                fit: BoxFit.cover,
              ),
            ),
            height: 127,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(
                  {
                    'episode': widget.episode,
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
                  widget.episode.title,
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
          Text(
            widget.episode.subtitle,
            style: const TextStyle(
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
