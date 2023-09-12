import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_app/data/downloaded_episode.dart';
import 'package:movie_app/database/database_utils.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tệp tải xuống'),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ListAllDownloadedFilm(),
            const _ListAllEpisode(),
          ],
        ));
  }
}

class _ListAllDownloadedFilm extends StatelessWidget {
  _ListAllDownloadedFilm();

  final _movieListKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'Phim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        AnimatedList(
          key: _movieListKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: offlineMovies.length,
          itemBuilder: (ctx, index, animation) {
            final movie = offlineMovies[index];
            return _OfflineMovie(
              episodeId: movie['seasons'][0]['episodes'][0]['id'],
              seasonId: movie['seasons'][0]['id'],
              filmId: movie['id'],
              filmName: movie['film_name'],
              posterPath: movie['poster_path'],
              movieListKey: _movieListKey,
            );
          },
        ),
        const SizedBox(
          height: 12,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'TV Series',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        // ...getTvSeries().map(
        //   (movie) => buildTvSeriesItem(
        //     movie['film_name'],
        //     movie['poster_path'],
        //   ),
        // ),
      ],
    );
  }

  Widget buildTvSeriesItem(String name, String posterPath) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(posterPath),
            width: 110,
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
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _OfflineMovie extends StatelessWidget {
  const _OfflineMovie({
    required this.episodeId,
    required this.seasonId,
    required this.filmId,
    required this.filmName,
    required this.posterPath,
    required this.movieListKey,
  });

  final String episodeId;
  final String seasonId;
  final String filmId;
  final String filmName;
  final String posterPath;
  final GlobalKey<AnimatedListState> movieListKey;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
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
                  '29 minutes',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton(
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

          print('remove film: $filmName');

          final episodeFile = File('${appDir.path}/episode/$episodeId.mp4');
          await episodeFile.delete();

          final databaseUtils = DatabaseUtils();
          await databaseUtils.connect();
          await databaseUtils.deleteEpisode(
            id: episodeId,
            seasonId: seasonId,
            filmId: filmId,
            deletePosterPath: () async {
              final posterFile = File('${appDir.path}/poster_path/$posterPath');
              await posterFile.delete();
            },
          );
          await databaseUtils.close();

          episodeIds.remove(episodeId);
          // offlineMovies.removeAt(movieIndex);

          final index =
              offlineMovies.indexWhere((element) => element['id'] == filmId);

          movieListKey.currentState!.removeItem(
            index,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: this,
            ),
          );

          offlineMovies.removeAt(index);
        },
      ),
    );
  }
}

class _ListAllEpisode extends StatelessWidget {
  const _ListAllEpisode();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      color: Colors.deepPurple,
    );
  }
}
