import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/models/poster.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:page_transition/page_transition.dart';

class GridFilms extends StatelessWidget {
  const GridFilms({
    super.key,
    required this.posters,
    this.canClick = true,
  });

  final List<Poster> posters;
  final bool canClick;

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
          final filmId = posters[index].filmId;
          return GestureDetector(
            onTap: canClick
                ? () {
                    String? prior =
                        context.read<RouteStackCubit>().findPrior('/film_detail@$filmId');
                    // print('prior = $prior');
                    /*
                    prior là route trước của /film_detail@$filmId
                    nếu /film_detail@$filmId có trong RouteStack
                    */

                    if (prior != null) {
                      // Trong Stack đã từng di chuyển tới Phim này rồi
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
                          // print(route.settings.name);
                          if (route.settings.name == prior) {
                            /*
                            Khi đã gặp prior route của /film_detail@$filmId
                            Thì push /film_detail@$filmId vào Stack
                            */
                            context.read<RouteStackCubit>().push('/film_detail@$filmId');
                            context.read<RouteStackCubit>().printRouteStack();
                            return true;
                          } else {
                            context.read<RouteStackCubit>().pop();
                            return false;
                          }
                        },
                      );
                    } else {
                      // Chưa từng di chuyển tới Phim này
                      context.read<RouteStackCubit>().push('/film_detail@$filmId');
                      context.read<RouteStackCubit>().printRouteStack();
                      Navigator.of(context).push(
                        PageTransition(
                          child: FilmDetail(
                            filmId: filmId,
                          ),
                          type: PageTransitionType.rightToLeft,
                          duration: 300.ms,
                          reverseDuration: 300.ms,
                          settings: RouteSettings(name: '/film_detail@$filmId'),
                        ),
                      );
                    }

                    // if ('/film_detail@$filmId' == context.read<RouteStackCubit>().top()) {
                    //   // Không fix code chỗ này
                    //   context.read<RouteStackCubit>().pop();
                    //   Navigator.of(context).pushAndRemoveUntil(
                    //     PageTransition(
                    //       child: FilmDetail(
                    //         filmId: filmId,
                    //       ),
                    //       type: PageTransitionType.rightToLeft,
                    //       duration: 300.ms,
                    //       reverseDuration: 300.ms,
                    //       settings: RouteSettings(name: '/film_detail@$filmId'),
                    //     ),
                    //     (route) {
                    //       return route.settings.name ==
                    //           context.read<RouteStackCubit>().top();
                    //     },
                    //   );
                    //   context.read<RouteStackCubit>().push('/film_detail@$filmId');
                    // } else {
                    //   Navigator.of(context).pushAndRemoveUntil(
                    //     PageTransition(
                    //       child: FilmDetail(
                    //         filmId: filmId,
                    //       ),
                    //       type: PageTransitionType.rightToLeft,
                    //       duration: 300.ms,
                    //       reverseDuration: 300.ms,
                    //     ),
                    //     (route) {
                    //       return route.settings.name ==
                    //           context.read<RouteStackCubit>().top();
                    //     },
                    //   );
                    // }
                  }
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://image.tmdb.org/t/p/w440_and_h660_face/${posters[index].posterPath}',
              ),
            ),
          );
        },
      ),
    );
  }
}
