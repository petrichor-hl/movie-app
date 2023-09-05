import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late final List<String> genres = [];
  late final _futureMovie = _fetchMovie();
  late final List<dynamic> _seasons;

  Future<void> _fetchMovie() async {
    _movie = await supabase
        .from('film')
        .select(
          'name, release_date, vote_average, vote_count, overview, backdrop_path, poster_path, content_rating, trailer',
        )
        .eq('id', widget.filmId)
        .single();

    final List<dynamic> genresData = await supabase
        .from('film_genre')
        .select('genre(name)')
        .eq('film_id', widget.filmId);

    for (final row in genresData) {
      genres.add(row['genre']['name']);
    }

    _seasons = await supabase
        .from('season')
        .select('name, episode(*)')
        .eq('film_id', widget.filmId)
        .order('id', ascending: true);

    // for (final season in seasons) {
    //   print(season['name']);
    // }
  }

  bool _isExpandOverview = false;

  int segmentIndex = 0;

  late String selectedSeason = _seasons[0]['name'];

  @override
  Widget build(BuildContext context) {
    print('Film ID = ${widget.filmId}');
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
                  height: 8,
                ),

                const Text(
                  'Thể loại:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        genres[0],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    for (int i = 1; i < genres.length; ++i)
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          ', ${genres[i]}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                // const SizedBox(
                //   height: 8,
                // ),
                // ActorsList(cast: cast),

                const SizedBox(
                  height: 20,
                ),
                CupertinoSlidingSegmentedControl(
                  backgroundColor: Colors.white.withAlpha(100),
                  thumbColor: Colors.black,
                  groupValue: segmentIndex,
                  children: {
                    0: buildSegment('Tập phim'),
                    1: buildSegment('Đề xuất'),
                  },
                  onValueChanged: (index) {
                    setState(() {
                      segmentIndex = index!;
                    });
                  },
                ),

                const SizedBox(
                  height: 8,
                ),

                AnimatedSwitcher(
                  duration: 100.ms,
                  child: segmentIndex == 0
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButton(
                              value: selectedSeason,
                              dropdownColor:
                                  const Color.fromARGB(255, 33, 33, 33),
                              style: GoogleFonts.montserrat(fontSize: 16),
                              items: List.generate(
                                _seasons.length,
                                (index) => DropdownMenuItem(
                                  value: _seasons[index]['name'] as String,
                                  child: Text(
                                    _seasons[index]['name'],
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedSeason = value;
                                  });
                                }
                              },
                            ),
                            ...(_seasons[0]['episode'] as List<dynamic>).map(
                              (e) {
                                return _Episode(
                                  e['still_path'],
                                  e['title'],
                                  e['runtime'],
                                  e['subtitle'],
                                );
                              },
                            ),
                          ],
                        )
                      : const SizedBox(
                          height: 500,
                          width: double.infinity,
                          key: ValueKey(2),
                          child: ColoredBox(color: Colors.grey),
                        ),
                ),
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

class TabBar extends StatelessWidget {
  const TabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Widget buildSegment(String text) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _Episode extends StatelessWidget {
  const _Episode(this.stillPath, this.title, this.runtime, this.subtitle);

  final String stillPath;
  final String title;
  final int runtime;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://www.themoviedb.org/t/p/w454_and_h254_bestv2$stillPath',
                  height: 72,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$runtime phút',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
