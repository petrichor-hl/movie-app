import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/data/downloaded_film.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/dtos/review_film.dart';
import 'package:movie_app/models/episode.dart';
import 'package:movie_app/models/film.dart';
import 'package:movie_app/models/genre.dart';
import 'package:movie_app/models/season.dart';
import 'package:movie_app/screens/films_by_genre.dart';
import 'package:movie_app/utils/common_variables.dart';
import 'package:movie_app/utils/extension.dart';
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
  late final Film _film;

  late final bool isMovie;
  bool _isExpandOverview = false;

  late final _futureMovie = _fetchMovie();

  final List<String> _downloadedEpisodeIds = [];

  Future<void> _fetchMovie() async {
    final filmInfo = await supabase
        .from('film')
        .select(
          'name, release_date, vote_average, vote_count, overview, backdrop_path, poster_path, content_rating, trailer',
        )
        .eq('id', widget.filmId)
        .single();

    // print('filmData = $filmInfo');

    _film = Film(
      id: widget.filmId,
      name: filmInfo['name'],
      releaseDate: DateTime.parse(filmInfo['release_date']),
      voteAverage: filmInfo['vote_average'],
      voteCount: filmInfo['vote_count'],
      overview: filmInfo['overview'],
      backdropPath: filmInfo['backdrop_path'],
      posterPath: filmInfo['poster_path'],
      contentRating: filmInfo['content_rating'],
      trailer: filmInfo['trailer'],
      genres: [],
      seasons: [],
      reviews: [],
    );
    // print('backdrop_path = ${_film!['backdrop_path']}');
    final List<dynamic> genresData =
        await supabase.from('film_genre').select('genre(*)').eq('film_id', widget.filmId);

    for (var genreRow in genresData) {
      _film.genres.add(
        Genre(
          genreId: genreRow['genre']['id'],
          name: genreRow['genre']['name'],
        ),
      );
    }

    // print(_film.genres.length);

    final List<dynamic> seasonsData = await supabase
        .from('season')
        .select('id, name, episode(*)')
        .eq('film_id', widget.filmId)
        .order('id', ascending: true)
        .order('order', referencedTable: 'episode', ascending: true);

    for (var seasonRow in seasonsData) {
      final season = Season(
        seasonId: seasonRow['id'],
        name: seasonRow['name'],
        episodes: [],
      );

      final List<dynamic> episodesData = seasonRow['episode'];
      // print(episodesData);

      for (final episodeRow in episodesData) {
        season.episodes.add(
          Episode(
            episodeId: episodeRow['id'],
            order: episodeRow['order'],
            stillPath: episodeRow['still_path'],
            title: episodeRow['title'],
            runtime: episodeRow['runtime'],
            subtitle: episodeRow['subtitle'],
            linkEpisode: episodeRow['link'],
          ),
        );
      }

      _film.seasons.add(season);
    }
    // print(_film.seasons.length);

    final List<dynamic> reviewsData = await supabase
        .from('review')
        .select('user_id, star, created_at, profile(full_name, avatar_url)')
        .eq('film_id', widget.filmId);

    // print(reviewsData);

    for (var element in reviewsData) {
      _film.reviews.add(
        ReviewFilm(
          userId: element['user_id'],
          hoTen: element['profile']['full_name'],
          avatarUrl: element['profile']['avatar_url'],
          star: element['star'],
          createAt: vnDateFormat.parse(element['created_at']),
        ),
      );
    }

    _film.reviews.sort((a, b) => b.createAt.compareTo(a.createAt));

    isMovie = _film.seasons[0].name == '';

    final existingDownloadedFilm = downloadedFilms[_film.id];
    if (existingDownloadedFilm != null) {
      for (var season in existingDownloadedFilm.offlineSeasons) {
        for (var episode in season.offlineEpisodes) {
          _downloadedEpisodeIds.add(episode.episodeId);
        }
      }
    }

    offlineData.addAll({
      'film_id': _film.id,
      'film_name': _film.name,
      'poster_path': _film.posterPath,
      'season_id': _film.seasons[0].seasonId,
      'season_name': _film.seasons[0].name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Đã test - Không sửa
      onWillPop: () async {
        context.read<RouteStackCubit>().pop();
        context.read<RouteStackCubit>().printRouteStack();
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

              double voteAverage = 0;
              if (_film.reviews.isNotEmpty) {
                voteAverage = _film.reviews
                        .fold(0, (previousValue, review) => previousValue + review.star) /
                    _film.reviews.length;

                // print(voteAverage);
              }

              final textPainter = TextPainter(
                text: TextSpan(
                  text: _film.overview,
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
                          'https://image.tmdb.org/t/p/original/${_film.backdropPath}',
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
                              _film.contentRating,
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
                      _film.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Phát hành: ${_film.releaseDate.toVnFormat()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatefulBuilder(builder: (ctx, setStateVoteAverage) {
                      return Row(
                        children: [
                          Text(
                            voteAverage == 0
                                ? 'Chưa có đánh giá'
                                : 'Điểm: ${voteAverage.toStringAsFixed(2)}',
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
                                  reviews: _film.reviews,
                                  onReviewHasChanged: () {
                                    setStateVoteAverage(() {
                                      voteAverage = _film.reviews.fold(
                                              0,
                                              (previousValue, review) =>
                                                  previousValue + review.star) /
                                          _film.reviews.length;
                                    });
                                  },
                                ),
                                /*
                                  Gỡ bỏ giới hạn của chiều cao của BottomSheet
                                  */
                                isScrollControlled: true,
                                // Không hoạt động useSafeArea
                                // useSafeArea: true,
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
                      );
                    }),
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
                                  filmId: _film.id,
                                  seasons: _film.seasons,
                                  downloadedEpisodeIds: _downloadedEpisodeIds,
                                  firstEpisodeToPlay: _film.seasons[0].episodes[0],
                                  firstSeasonIndex: 0,
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
                        firstEpisodeId: _film.seasons[0].episodes[0].episodeId,
                        firstEpisodeLink: _film.seasons[0].episodes[0].linkEpisode,
                        runtime: _film.seasons[0].episodes[0].runtime,
                        isEpisodeDownloaded: _downloadedEpisodeIds
                            .contains(_film.seasons[0].episodes[0].episodeId),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      _film.overview,
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
                            final genreId = _film.genres[0].genreId;

                            String? prior = context
                                .read<RouteStackCubit>()
                                .findPrior('/films_by_genre@$genreId');
                            /*
                            prior là route trước của /person_detail@${personsData[index]['person']['id']}
                            nếu /person_detail@${personsData[index]['person']['id']} có trong RouteStack
                            */
                            if (prior != null) {
                              // Trong Stack đã từng di chuyển tới films_by_genre này rồi
                              Navigator.of(context).pushAndRemoveUntil(
                                PageTransition(
                                  child: FilmsByGenre(
                                    genreId: genreId,
                                    genreName: _film.genres[0].name,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                  duration: 300.ms,
                                  reverseDuration: 300.ms,
                                  settings:
                                      RouteSettings(name: '/films_by_genre@$genreId'),
                                ),
                                (route) {
                                  if (route.settings.name == prior) {
                                    /*
                                    Khi đã gặp prior route của /films_by_genre@$genreId
                                    Thì push /films_by_genre@$genreId vào Stack
                                    */
                                    context
                                        .read<RouteStackCubit>()
                                        .push('/films_by_genre@$genreId');
                                    context.read<RouteStackCubit>().printRouteStack();
                                    return true;
                                  } else {
                                    context.read<RouteStackCubit>().pop();
                                    return false;
                                  }
                                },
                              );
                            } else {
                              // Chưa từng di chuyển tới films_by_genre này
                              context
                                  .read<RouteStackCubit>()
                                  .push('/films_by_genre@$genreId');
                              context.read<RouteStackCubit>().printRouteStack();
                              Navigator.of(context).push(
                                PageTransition(
                                  child: FilmsByGenre(
                                    genreId: genreId,
                                    genreName: _film.genres[0].name,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                  duration: 300.ms,
                                  reverseDuration: 300.ms,
                                  settings:
                                      RouteSettings(name: '/films_by_genre@$genreId'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            _film.genres[0].name,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        for (int i = 1; i < _film.genres.length; ++i)
                          GestureDetector(
                            onTap: () {
                              final genreId = _film.genres[i].genreId;
                              context
                                  .read<RouteStackCubit>()
                                  .push('/films_by_genre@$genreId');
                              context.read<RouteStackCubit>().printRouteStack();
                              Navigator.of(context).push(
                                PageTransition(
                                  child: FilmsByGenre(
                                    genreId: genreId,
                                    genreName: _film.genres[i].name,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                  duration: 300.ms,
                                  reverseDuration: 300.ms,
                                  settings:
                                      RouteSettings(name: '/films_by_genre@$genreId'),
                                ),
                              );
                            },
                            child: Text(
                              ', ${_film.genres[i].name}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SegmentCompose(
                      _film.seasons,
                      isMovie,
                      widget.filmId,
                      _downloadedEpisodeIds,
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
        ),
      ),
    );
  }
}
