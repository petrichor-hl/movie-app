import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/dtos/review_film.dart';
import 'package:movie_app/screens/films_by_genre.dart';
import 'package:movie_app/utils/common_variables.dart';
import 'package:movie_app/widgets/film_detail/download_button.dart';
import 'package:movie_app/widgets/film_detail/favorite_button.dart';
import 'package:movie_app/widgets/film_detail/reviews_bottom_sheet.dart';
import 'package:movie_app/widgets/film_detail/segment_compose.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';
import 'package:page_transition/page_transition.dart';

final Map<String, dynamic> offlineData = {};

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
  late final Map<String, dynamic>? _film;
  late final List<dynamic> genres;
  late final List<dynamic> _seasons;
  final List<ReviewFilm> _reviews = [];

  late final bool isMovie;
  bool _isExpandOverview = false;

  late final _futureMovie = _fetchMovie();

  Future<void> _fetchMovie() async {
    _film = await supabase
        .from('film')
        .select(
          'id, name, release_date, vote_average, vote_count, overview, backdrop_path, poster_path, content_rating, trailer',
        )
        .eq('id', widget.filmId)
        .single();
    // print('backdrop_path = ${_film!['backdrop_path']}');

    genres =
        await supabase.from('film_genre').select('genre(*)').eq('film_id', widget.filmId);

    _seasons = await supabase
        .from('season')
        .select('id, name, episode(*)')
        .eq('film_id', widget.filmId)
        .order('id', ascending: true)
        .order('order', foreignTable: 'episode', ascending: true);

    final List<dynamic> reviewsData = await supabase
        .from('review')
        .select('user_id, star, created_at, profile(full_name, avatar_url)')
        .eq('film_id', widget.filmId);

    // print(reviewsData);

    for (var element in reviewsData) {
      _reviews.add(
        ReviewFilm(
          userId: element['user_id'],
          hoTen: element['profile']['full_name'],
          avatarUrl: element['profile']['avatar_url'],
          star: element['star'],
          createAt: vnDateFormat.parse(element['created_at']),
        ),
      );
    }

    _reviews.sort((a, b) => b.createAt.compareTo(a.createAt));

    isMovie = _seasons[0]['name'] == null;

    offlineData.addAll({
      'film_id': _film!['id'],
      'film_name': _film!['name'],
      'poster_path': _film!['poster_path'],
      'season_id': _seasons[0]['id'],
      'season_name': _seasons[0]['name'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Đã test - Không sửa
      onWillPop: () async {
        if (context.read<RouteStackCubit>().top().contains(_film!['id'])) {
          context.read<RouteStackCubit>().pop();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            Assets.viovidLogo,
            width: 120,
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          actions: [
            BlocBuilder<MyListCubit, List<String>>(
              builder: (context, state) {
                return FavoriteButton(
                  filmId: widget.filmId,
                  isInMyList: state.contains(widget.filmId),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: _futureMovie,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Có lỗi xảy ra khi truy vấn thông tin phim',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // print('film_id = ' + offlineData['film_id']);

              final textPainter = TextPainter(
                text: TextSpan(
                  text: _film!['overview'],
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
                          'https://image.tmdb.org/t/p/original/${_film!['backdrop_path']}',
                          width: double.infinity,
                          height: 9 / 16 * MediaQuery.sizeOf(context).width,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.black,
                              border: Border.all(
                                width: 1,
                                color: Colors.white,
                              ),
                            ),
                            child: Text(
                              _film!['content_rating'],
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
                      _film!['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Phát hành: ${DateFormat('dd-MM-yyyy').format(
                        DateTime.parse(_film!['release_date']),
                      )}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Điểm: ${(_film!['vote_average'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => ReviewsBottomSheet(
                                reviews: _reviews,
                              ),
                              /*
                              Gỡ bỏ giới hạn của chiều cao của BottomSheet
                              */
                              isScrollControlled: true,
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white30,
                            ),
                            child: const Text(
                              'Xem chi tiết',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final episodeId = _seasons[0]['episode'][0]['id'];
                          final isDownloaded = downloadedEpisodeId.contains(episodeId);
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
                                child: isDownloaded
                                    ? VideoPlayerView(
                                        title: _film!['name'],
                                        videoLink: isMovie
                                            ? '${appDir.path}/episode/$episodeId.mp4'
                                            : '${appDir.path}/episode/${_film!['id']}/$episodeId.mp4',
                                        videoLocation: 'local',
                                      )
                                    : VideoPlayerView(
                                        title: _film!['name'],
                                        videoLink: _seasons[0]['episode'][0]['link'],
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
                    if (isMovie)
                      DownloadButton(
                        firstEpisodeId: _seasons[0]['episode'][0]['id'],
                        firstEpisodeLink: _seasons[0]['episode'][0]['link'],
                        runtime: _seasons[0]['episode'][0]['runtime'],
                      ),
                    const SizedBox(height: 6),
                    Text(
                      _film!['overview'],
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
                    const SizedBox(height: 8),
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
                            final genreId = genres[0]['genre']['id'];
                            if (context
                                .read<RouteStackCubit>()
                                .top()
                                .contains('/films_by_genre')) {
                              context.read<RouteStackCubit>().pop();
                            }

                            Navigator.of(context).pushAndRemoveUntil(
                              PageTransition(
                                child: FilmsByGenre(
                                  genreId: genreId,
                                  genreName: genres[0]['genre']['name'],
                                ),
                                type: PageTransitionType.rightToLeft,
                                duration: 300.ms,
                                reverseDuration: 300.ms,
                                settings: RouteSettings(name: '/films_by_genre@$genreId'),
                              ),
                              (route) {
                                return route.settings.name ==
                                    context.read<RouteStackCubit>().top();
                              },
                            );
                            context
                                .read<RouteStackCubit>()
                                .push('/films_by_genre@$genreId');
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
                              final genreId = genres[i]['genre']['id'];
                              if (context
                                  .read<RouteStackCubit>()
                                  .top()
                                  .contains('/films_by_genre')) {
                                context.read<RouteStackCubit>().pop();
                              }
                              Navigator.of(context).pushAndRemoveUntil(
                                PageTransition(
                                  child: FilmsByGenre(
                                    genreId: genreId,
                                    genreName: genres[i]['genre']['name'],
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                  duration: 300.ms,
                                  reverseDuration: 300.ms,
                                  settings:
                                      RouteSettings(name: '/films_by_genre@$genreId'),
                                ),
                                (route) {
                                  return route.settings.name ==
                                      context.read<RouteStackCubit>().top();
                                },
                              );
                              context
                                  .read<RouteStackCubit>()
                                  .push('/films_by_genre@$genreId');
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
                    const SizedBox(height: 20),
                    SegmentCompose(_seasons, isMovie, widget.filmId),
                  ],
                ).animate().fade().slideY(
                      curve: Curves.easeInOut,
                      begin: 0.1,
                      end: 0,
                    ),
              );
            },
          ),
        ),
      ),
    );
  }
}
