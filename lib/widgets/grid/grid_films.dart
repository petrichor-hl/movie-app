import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:page_transition/page_transition.dart';

class GridFilms extends StatelessWidget {
  const GridFilms({
    super.key,
    required this.posters,
  });

  final List<dynamic> posters;

  @override
  Widget build(BuildContext context) {
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
        posters.length,
        (index) {
          final filmId = posters[index]['film']['id'];
          return GestureDetector(
            onTap: () {
              // print('current: ${context.read<RouteStackCubit>().state}');
              // print('top_stack: ${context.read<RouteStackCubit>().top()}');

              // print('film_id: $filmId');
              // print(
              //     "FilmID trùng với top_stack: ${'/film_detail@${posters[index]['film']['id']}' == context.read<RouteStackCubit>().top()}");

              if ('/film_detail@$filmId' == context.read<RouteStackCubit>().top()) {
                // Không fix code chỗ này
                context.read<RouteStackCubit>().pop();
                Navigator.of(context).pushAndRemoveUntil(
                  PageTransition(
                    child: FilmDetail(
                      filmId: filmId,
                    ),
                    type: PageTransitionType.rightToLeft,
                    duration: 300.ms,
                    reverseDuration: 300.ms,
                    settings: RouteSettings(name: '/film_detail@$filmId'),
                  ),
                  (route) {
                    return route.settings.name == context.read<RouteStackCubit>().top();
                  },
                );
                context.read<RouteStackCubit>().push('/film_detail@$filmId');
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  PageTransition(
                    child: FilmDetail(
                      filmId: filmId,
                    ),
                    type: PageTransitionType.rightToLeft,
                    duration: 300.ms,
                    reverseDuration: 300.ms,
                  ),
                  (route) {
                    return route.settings.name == context.read<RouteStackCubit>().top();
                  },
                );
              }
              //     Navigator.of(context).pushAndRemoveUntil(
              //       PageTransition(
              //         child: FilmDetail(
              //           filmId: posters[index]['film']['id'],
              //         ),
              //         type: PageTransitionType.rightToLeft,
              //         duration: 300.ms,
              //         reverseDuration: 300.ms,
              //         settings:
              //             RouteSettings(name: '/film_detail@${posters[index]['film']['id']}'),
              //       ),
              //       (route) {
              //         // print('route: ${route.settings.name}');
              //         return route.settings.name == context.read<RouteStackCubit>().top();
              //       },
              //     );
              //   } else {
              // Navigator.of(context).pushAndRemoveUntil(
              //   PageTransition(
              //     child: FilmDetail(
              //       filmId: posters[index]['film']['id'],
              //     ),
              //     type: PageTransitionType.rightToLeft,
              //     duration: 300.ms,
              //     reverseDuration: 300.ms,
              //   ),
              //   (route) {
              //     // print('route: ${route.settings.name}');
              //     return route.settings.name == context.read<RouteStackCubit>().top();
              //   },
              // );
              //   }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://image.tmdb.org/t/p/w440_and_h660_face/${posters[index]['film']['poster_path']}',
              ),
            ),
          );
        },
      ),
    );
  }
}
