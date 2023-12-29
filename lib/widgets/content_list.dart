import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/models/poster.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:page_transition/page_transition.dart';

class ContentList extends StatelessWidget {
  const ContentList({
    super.key,
    required this.title,
    required this.films,
    this.isOriginals = false,
  });

  final String title;
  final List<Poster> films;
  final bool isOriginals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 16, bottom: 6),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: isOriginals ? 360 : 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final film = films[index];
              return GestureDetector(
                onTap: () async {
                  context.read<RouteStackCubit>().push('/film_detail@${film.filmId}');
                  context.read<RouteStackCubit>().printRouteStack();
                  await Navigator.of(context).push(
                    PageTransition(
                      child: FilmDetail(filmId: film.filmId),
                      type: PageTransitionType.rightToLeft,
                      duration: 300.ms,
                      reverseDuration: 300.ms,
                      settings: RouteSettings(name: '/film_detail@${film.filmId}'),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isOriginals ? 240 : 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image(
                    image: NetworkImage(
                      isOriginals
                          ? 'https://image.tmdb.org/t/p/w600_and_h900_bestv2/${film.posterPath}'
                          : 'https://image.tmdb.org/t/p/w440_and_h660_face/${film.posterPath}',
                    ),
                    fit: BoxFit.cover,
                    // https://api.flutter.dev/flutter/widgets/Image/frameBuilder.html
                    frameBuilder: (
                      BuildContext context,
                      Widget child,
                      int? frame,
                      bool wasSynchronouslyLoaded,
                    ) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(
                          milliseconds: 500,
                        ), // Adjust the duration as needed
                        curve: Curves.easeInOut,
                        child: child, // Adjust the curve as needed
                      );
                    },
                    // https://api.flutter.dev/flutter/widgets/Image/loadingBuilder.html
                    loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: SizedBox(
                          width: isOriginals ? 48 : 36,
                          height: isOriginals ? 48 : 36,
                          child: const CircularProgressIndicator(
                            // value: loadingProgress.expectedTotalBytes != null
                            //     ? loadingProgress.cumulativeBytesLoaded /
                            //         loadingProgress.expectedTotalBytes!
                            //     : null,
                            color: Colors.grey,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            itemCount: films.length,
          ),
        )
      ],
    );
  }
}
