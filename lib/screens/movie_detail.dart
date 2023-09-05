import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';

class MovieDeital extends StatefulWidget {
  const MovieDeital({
    super.key,
    required this.filmId,
  });

  final String filmId;

  @override
  State<MovieDeital> createState() => _MovieDeitalState();
}

class _MovieDeitalState extends State<MovieDeital> {
  late final Map<String, dynamic>? _movie;
  late final _futureMovie = _fetchMovie();

  Future<void> _fetchMovie() async {
    _movie = await supabase
        .from('film')
        .select(
          'name, release_date, vote_average, vote_count, overview, backdrop_path, poster_path, content_rating, trailer',
        )
        .eq('id', widget.filmId)
        .single();
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
              text: _movie!['overview'],
              style: const TextStyle(color: Colors.white),
            ),
            maxLines: 4,
            textDirection: dart_ui.TextDirection.ltr,
          )..layout(minWidth: 0, maxWidth: MediaQuery.sizeOf(context).width);

          final isOverflowed = textPainter.didExceedMaxLines;

          // String genresText = '';
          // List<dynamic> genres = movie!['genres'];
          // if (genres.isNotEmpty) {
          //   genresText =
          //       (genres[0]['name'] as String).replaceFirst('Phim ', '');
          // }
          // for (int i = 1; i < genres.length; ++i) {
          //   genresText +=
          //       ' - ${(genres[i]['name'] as String).replaceFirst('Phim ', '')}';
          // }
          // final List<dynamic> cast = movie!['credits']['cast'];

          DateTime releaseDate = DateTime.parse(_movie!['release_date']);
          String formattedDate = DateFormat('dd-MM-yyyy').format(releaseDate);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/original/${_movie!['backdrop_path']}',
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Text(
                  _movie!['name'],
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
                  'Điểm: ${(_movie!['vote_average'] as double).toStringAsFixed(2)}',
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
                          builder: (ctx) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (ctx) => VideoSliderCubit(),
                              ),
                              BlocProvider(
                                create: (ctx) => VideoPlayControlCubit(),
                              ),
                            ],
                            child: VideoPlayerView(
                              title: _movie!['name'],
                              episodeUrl:
                                  'https://kpaxjjmelbqpllxenpxz.supabase.co/storage/v1/object/public/film/jujutsu_kaisen/season_1/jujutsu_kaisen_trailer.mp4?t=2023-09-01T12%3A34%3A55.249Z',
                            ),
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
                Text(
                  _movie!['overview'],
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
                const SizedBox(
                  height: 12,
                ),

                // if (genres.isNotEmpty)
                //   const Text(
                //     'Thể loại:',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // if (genres.isNotEmpty)
                //   Text(
                //     genresText,
                //     style: const TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                const SizedBox(
                  height: 12,
                ),
                // ActorsList(cast: cast),
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
