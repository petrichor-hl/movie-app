import 'dart:io';
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
import 'package:movie_app/database/database_utils.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/films_by_genre.dart';
import 'package:movie_app/widgets/episode.dart';
import 'package:movie_app/widgets/grid/grid_persons.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';

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
  late final Map<String, dynamic>? _movie;
  late final List<dynamic> genres;
  late final _futureMovie = _fetchMovie();
  late final List<dynamic> _seasons;
  late final isMovie = _seasons[0]['name'] == null;

  bool _isExpandOverview = false;

  Future<void> _fetchMovie() async {
    _movie = await supabase
        .from('film')
        .select(
          'id, name, release_date, vote_average, vote_count, overview, backdrop_path, poster_path, content_rating, trailer',
        )
        .eq('id', widget.filmId)
        .single();

    genres = await supabase
        .from('film_genre')
        .select('genre(*)')
        .eq('film_id', widget.filmId);

    _seasons = await supabase
        .from('season')
        .select('id, name, episode(*)')
        .eq('film_id', widget.filmId)
        .order('id', ascending: true)
        .order('order', foreignTable: 'episode', ascending: true);

    offlineData.addAll({
      'film_id': _movie!['id'],
      'film_name': _movie!['name'],
      'backdrop_path': _movie!['backdrop_path'],
      'season_id': _seasons[0]['id'],
      'season_name': _seasons[0]['name'],
    });
  }

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
            return const Center(
              child: Text(
                'Có lỗi xảy ra khi truy vấn thông tin phim',
                style: TextStyle(color: Colors.white),
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
                              episodeUrl: _seasons[0]['episode'][0]['link'],
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
                const SizedBox(height: 20),
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

class _ListEpisodes extends StatefulWidget {
  const _ListEpisodes(this.seasons);

  final List<dynamic> seasons;

  @override
  State<_ListEpisodes> createState() => __ListEpisodesState();
}

class __ListEpisodesState extends State<_ListEpisodes> {
  int selectedSeason = 0;

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
            if (value != null && value != selectedSeason) {
              setState(() {
                selectedSeason = value;
              });
              offlineData['season_id'] = widget.seasons[value]['id'];
              offlineData['season_name'] = widget.seasons[value]['name'];
              // print('offine_data = $offlineData');
            }
          },
        ),
        const SizedBox(height: 12),
        ...(widget.seasons[selectedSeason]['episode'] as List<dynamic>).map(
          (e) {
            return Episode(
              e['id'],
              e['still_path'],
              e['title'],
              e['runtime'],
              e['subtitle'],
              e['link'],
              key: ValueKey(e['id']),
            );
          },
        ),
      ],
    );
  }
}

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.firstEpisodeLink,
    required this.firstEpisodeId,
    required this.runtime,
  });

  final String firstEpisodeLink;
  final String firstEpisodeId;
  final int runtime;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  late final widthButton = MediaQuery.sizeOf(context).width;
  double progress = 0;

  var downloadState = DownloadState.ready;

  @override
  Widget build(BuildContext context) {
    return downloadState == DownloadState.downloaded
        ? SizedBox(
            height: 40,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        MenuItemButton(
                          trailingIcon: const Icon(Icons.delete),
                          child: const Text('Xoá tệp tải xuống'),
                          onPressed: () async {
                            final appDir =
                                await getApplicationDocumentsDirectory();
                            final episodeFile = File(
                                '${appDir.path}/episode/${widget.firstEpisodeId}.mp4');
                            await episodeFile.delete();

                            final databaseUtils = DatabaseUtils();
                            await databaseUtils.connect();
                            await databaseUtils.deleteEpisode(
                              id: widget.firstEpisodeId,
                              seasonId: offlineData['season_id'],
                              filmId: offlineData['film_id'],
                              deleteBackdropPath: () async {
                                final backdropPathFile = File(
                                    '${appDir.path}/backdrop_path${offlineData['backdrop_path']}');
                                await backdropPathFile.delete();
                              },
                            );
                            await databaseUtils.close();

                            setState(() {
                              downloadState = DownloadState.ready;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xoá tập phim tải xuống'),
                                ),
                              );
                            });
                          },
                        ),
                        MenuItemButton(
                          trailingIcon: const Icon(Icons.download_for_offline),
                          child: const Text('Xem Nội dung tải xuống của tôi'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.download_done),
              label: const Text(
                'Đã tải xuống',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(36, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )
        : InkWell(
            onTap: downloadState == DownloadState.ready
                ? () async {
                    setState(() {
                      downloadState = DownloadState.downloading;
                    });

                    final appDir = await getApplicationDocumentsDirectory();
                    // print('download to: $appDir');

                    // 1. download video
                    await Dio().download(
                      widget.firstEpisodeLink,
                      '${appDir.path}/episode/${widget.firstEpisodeId}.mp4',
                      onReceiveProgress: (count, total) {
                        setState(() {
                          progress = count / total;
                        });
                      },
                      deleteOnError: true,
                    );

                    // 2. download film's backdrop_path
                    final backdropLocalPath =
                        '${appDir.path}/backdrop_path${offlineData['backdrop_path']}';
                    final file = File(backdropLocalPath);
                    if (!await file.exists()) {
                      await Dio().download(
                        'https://image.tmdb.org/t/p/w1280/${offlineData['backdrop_path']}',
                        backdropLocalPath,
                        deleteOnError: true,
                      );
                    }

                    // Insert data to local database
                    final databaseUtils = DatabaseUtils();
                    await databaseUtils.connect();
                    await databaseUtils.insertFilm(
                      offlineData['film_id'],
                      offlineData['film_name'],
                      offlineData['backdrop_path'],
                    );

                    await databaseUtils.insertSeason(
                      id: offlineData['season_id'],
                      filmId: offlineData['film_id'],
                    );

                    await databaseUtils.insertEpisode(
                      id: widget.firstEpisodeId,
                      runtime: widget.runtime,
                      seasonId: offlineData['season_id'],
                    );

                    await databaseUtils.close();

                    setState(() {
                      downloadState = DownloadState.downloaded;
                      progress = 0;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color.fromARGB(36, 255, 255, 255),
                  ),
                  width: double.infinity,
                  height: 40,
                ),
                if (downloadState == DownloadState.downloading)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.amber,
                      ),
                      width: widthButton * progress,
                    ),
                  ),
                if (downloadState == DownloadState.ready)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tải xuống',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                if (downloadState == DownloadState.downloading)
                  Text(
                    'Đang tải ... ${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
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
