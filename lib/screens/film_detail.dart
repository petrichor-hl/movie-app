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
import 'package:movie_app/screens/films_by_genre.dart';
import 'package:movie_app/widgets/grid/grid_persons.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

class FilmDetail extends StatefulWidget {
  const FilmDetail({
    super.key,
    required this.filmId,
  });

  final String filmId;

  @override
  State<FilmDetail> createState() => _FilmDetailState();
}

class _FilmDetailState extends State<FilmDetail> {
  late final Map<String, dynamic>? _movie;
  late final List<dynamic> genres;
  late final _futureMovie = _fetchMovie();
  late final List<dynamic> _seasons;
  late final isMovie = _seasons[0]['name'] == null;

  Future<void> _fetchMovie() async {
    _movie = await supabase
        .from('film')
        .select(
          'name, release_date, vote_average, vote_count, overview, backdrop_path, poster_path, content_rating, trailer',
        )
        .eq('id', widget.filmId)
        .single();

    genres = await supabase
        .from('film_genre')
        .select('genre(*)')
        .eq('film_id', widget.filmId);

    _seasons = await supabase
        .from('season')
        .select('name, episode(*)')
        .eq('film_id', widget.filmId)
        .order('id', ascending: true)
        .order('order', foreignTable: 'episode', ascending: true);
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
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/original/${_movie!['backdrop_path']}',
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black,
                          border: Border.all(
                            width: 1,
                            color: Colors.white,
                          ),
                        ),
                        child: Text(
                          _movie!['content_rating'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
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
                  'Phát hành: ${DateFormat('dd-MM-yyyy').format(
                    DateTime.parse(_movie!['release_date']),
                  )}',
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
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          PageTransition(
                            child: ListFilmsByGenre(
                              genreId: genres[0]['genre']['id'],
                              genreName: genres[0]['genre']['name'],
                            ),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: Text(
                        genres[0]['genre']['name'],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    for (int i = 1; i < genres.length; ++i)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            PageTransition(
                              child: ListFilmsByGenre(
                                genreId: genres[i]['genre']['id'],
                                genreName: genres[i]['genre']['name'],
                              ),
                              type: PageTransitionType.fade,
                            ),
                          );
                        },
                        child: Text(
                          ', ${genres[i]['genre']['name']}',
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
                _SegmentCompose(_seasons, isMovie, widget.filmId),
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

class _SegmentCompose extends StatefulWidget {
  const _SegmentCompose(this.seasons, this.isMovie, this.filmId);

  final List<dynamic> seasons;
  final bool isMovie;
  final String filmId;

  @override
  State<_SegmentCompose> createState() => _SegmentComposeState();
}

class _SegmentComposeState extends State<_SegmentCompose> {
  late int _segmentIndex = widget.isMovie ? 1 : 0;
  late final _listEpisodes = _ListEpisodes(widget.seasons);
  final _gridShimmer = const _GridShimmer();

  late final List<dynamic> _castData;
  late final _futureCastData = _fetchCastData();

  late final List<dynamic> _crewData;
  late final _futureCrewData = _fetchCrewData();

  Future<void> _fetchCastData() async {
    _castData = await supabase
        .from('cast')
        .select('role: character, person(id, name, profile_path, popularity)')
        .eq('film_id', widget.filmId);

    _castData.sort((a, b) =>
        b['person']['popularity'].compareTo(a['person']['popularity']));
  }

  Future<void> _fetchCrewData() async {
    _crewData = await supabase
        .from('crew')
        .select('role: job, person(id, name, profile_path, popularity, gender)')
        .eq('film_id', widget.filmId);

    _crewData.sort((a, b) =>
        b['person']['popularity'].compareTo(a['person']['popularity']));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: CupertinoSlidingSegmentedControl(
            backgroundColor: Colors.white.withAlpha(36),
            thumbColor: Colors.black,
            groupValue: _segmentIndex,
            children: widget.isMovie
                ? {
                    1: buildSegment('Đề xuất'),
                    2: buildSegment('Diễn viên'),
                    3: buildSegment('Đội ngũ'),
                  }
                : {
                    0: buildSegment('Tập phim'),
                    1: buildSegment('Đề xuất'),
                    2: buildSegment('Diễn viên'),
                    3: buildSegment('Đội ngũ'),
                  },
            onValueChanged: (index) {
              setState(() {
                _segmentIndex = index!;
              });
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AnimatedSwitcher(
          duration: 100.ms,
          child: switch (_segmentIndex) {
            0 => _listEpisodes,
            2 => FutureBuilder(
                future: _futureCastData,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _gridShimmer;
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      'Truy xuất thông tin Diễn viên thất bại',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    );
                  }

                  return GridPersons(personsData: _castData);
                },
              ),
            3 => FutureBuilder(
                future: _futureCrewData,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _gridShimmer;
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      'Truy xuất thông tin Đội ngũ thất bại',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    );
                  }

                  return GridPersons(
                    personsData: _crewData,
                    isCast: false,
                  );
                },
              ),
            _ => null,
          },
        ),
      ],
    );
  }
}

Widget buildSegment(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
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
  const _Episode(this.stillPath, this.title, this.runtime, this.subtitle,
      this.linkEpisode);

  final String stillPath;
  final String title;
  final int runtime;
  final String subtitle;
  final String linkEpisode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: InkWell(
        onTap: () {
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
                  title: title,
                  episodeUrl: linkEpisode,
                ),
              ),
            ),
          );
        },
        splashColor: const Color.fromARGB(255, 52, 52, 52),
        borderRadius: BorderRadius.circular(4),
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
                    height: 80,
                    width: 143,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
          ],
        ),
      ),
    );
  }
}

class _ListEpisodes extends StatefulWidget {
  const _ListEpisodes(this.seasons);

  final List<dynamic> seasons;

  @override
  State<_ListEpisodes> createState() => __ListEpisodesState();
}

class __ListEpisodesState extends State<_ListEpisodes> {
  late int selectedSeason = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton(
          value: selectedSeason,
          dropdownColor: const Color.fromARGB(255, 33, 33, 33),
          style: GoogleFonts.montserrat(fontSize: 16),
          isDense: true,
          items: List.generate(
            widget.seasons.length,
            (index) => DropdownMenuItem(
              value: index,
              child: Text(
                widget.seasons[index]['name'],
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
        const SizedBox(height: 12),
        ...(widget.seasons[selectedSeason]['episode'] as List<dynamic>).map(
          (e) {
            return _Episode(
              e['still_path'],
              e['title'],
              e['runtime'],
              e['subtitle'],
              e['link'],
            );
          },
        ),
      ],
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    // Để tạo một Grid không chiếm toàn bộ khoảng trống => Sử dụng shrinkWrap = true
    // Làm cho Grid không cuộn được => set physics = NeverScrollableScrollPhysics();

    // Cách 1: Đơn giản
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      children: List.generate(
        12,
        (index) => Shimmer.fromColors(
          baseColor: Colors.white.withAlpha(100),
          highlightColor: Colors.grey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: Colors.white.withAlpha(100),
            ),
          ),
        ),
      ),
    );

    // or
    // Cách 2:
    // return CustomScrollView(
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(), // Disable scrolling
    //   slivers: [
    //     SliverGrid(
    //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: 3, // Number of columns
    //         mainAxisSpacing: 10,
    //         crossAxisSpacing: 10,
    //         childAspectRatio: 2 / 3,
    //       ),
    //       delegate: SliverChildBuilderDelegate(
    //         (ctx, index) {
    //           // Replace this with your colored boxes or widgets
    //           return Shimmer.fromColors(
    //             baseColor: Colors.white.withAlpha(100),
    //             highlightColor: Colors.grey,
    //             child: ClipRRect(
    //               borderRadius: BorderRadius.circular(4),
    //               child: ColoredBox(
    //                 color: Colors.white.withAlpha(100),
    //               ),
    //             ),
    //           );
    //         },
    //         childCount: 12, // Number of boxes in the grid
    //       ),
    //     ),
    //   ],
    // );;
  }
}
