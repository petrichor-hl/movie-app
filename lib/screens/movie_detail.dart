import 'dart:convert';
import 'dart:math';
import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/widgets/video_player_view.dart';

class MovieDeital extends StatefulWidget {
  const MovieDeital({super.key});

  @override
  State<MovieDeital> createState() => _MovieDeitalState();
}

class _MovieDeitalState extends State<MovieDeital> {
  Map<String, dynamic>? movie;
  late final _futureMovie = _fetchMovie();

  Future<void> _fetchMovie() async {
    final http.Response response;
    int randomMovieId = Random().nextInt(600);
    try {
      final Uri uri =
          Uri.https('api.themoviedb.org', '/3/movie/$randomMovieId', {
        'api_key': tmdbApiKey,
        'append_to_response': 'credits',
        'language': 'vi-VN',
      });
      response = await http.get(uri);
    } catch (error) {
      // print('Error in try catch');
      return;
    }

    if (response.statusCode >= 400 || response.body == 'null') {
      throw Exception('404 Not Found');
    }

    movie = json.decode(response.body);
  }

  bool _isExpandOverview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Assets.netflixLogo,
          width: 140,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureMovie,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final textPainter = TextPainter(
            text: TextSpan(
              text: movie == null ? '' : movie!['overview'],
              style: const TextStyle(color: Colors.white),
            ),
            maxLines: 4,
            textDirection: dart_ui.TextDirection.ltr,
          )..layout(minWidth: 0, maxWidth: MediaQuery.sizeOf(context).width);

          final isOverflowed = textPainter.didExceedMaxLines;

          String genresText = '';
          List<dynamic> genres = movie!['genres'];
          if (genres.isNotEmpty) {
            genresText =
                (genres[0]['name'] as String).replaceFirst('Phim ', '');
          }
          for (int i = 1; i < genres.length; ++i) {
            genresText +=
                ' - ${(genres[i]['name'] as String).replaceFirst('Phim ', '')}';
          }
          final List<dynamic> cast = movie!['credits']['cast'];

          DateTime releaseDate = DateTime.parse(movie!['release_date']);
          String formattedDate = DateFormat('dd-MM-yyyy').format(releaseDate);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/original/${movie!['backdrop_path']}',
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Text(
                  movie!['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 12),
                Text(
                  'Phát hành: $formattedDate',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Điểm: ${(movie!['vote_average'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const VideoPlayerView(
                            title: 'Episode 1',
                            episodeUrl: 'assets/videos/fly_away.mp4',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Phát',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Tải xuống'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: const Color.fromARGB(36, 255, 255, 255),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                if (movie!['overview'] != '')
                  Text(
                    movie!['overview'],
                    style: const TextStyle(color: Colors.white),
                    maxLines: _isExpandOverview ? null : 4,
                    textAlign: TextAlign.justify,
                  ),
                if (isOverflowed)
                  InkWell(
                    onTap: () => setState(() {
                      _isExpandOverview = !_isExpandOverview;
                    }),
                    child: Text(
                      _isExpandOverview ? 'Ẩn bớt' : 'Xem thêm',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (movie!['overview'] != '')
                  const SizedBox(
                    height: 12,
                  ),
                if (genres.isNotEmpty)
                  const Text(
                    'Thể loại:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (genres.isNotEmpty)
                  Text(
                    genresText,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(
                  height: 12,
                ),
                ActorsList(cast: cast),
              ],
            ).animate().fade().slideY(
                  curve: Curves.easeInOut,
                  begin: 0.1,
                  end: 0,
                ),
          );
        },
      ),
    );
  }
}

class ActorsList extends StatelessWidget {
  const ActorsList({
    super.key,
    required this.cast,
  });

  final List cast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Diễn viên',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            itemBuilder: (ctx, index) => cast[index]['profile_path'] != null
                ? Stack(
                    children: [
                      Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: NetworkImage(
                                'https://image.tmdb.org/t/p/original/${cast[index]['profile_path']}',
                              ),
                              fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        right: 18,
                        bottom: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            cast[index]['original_name'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
            itemCount: cast.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}
