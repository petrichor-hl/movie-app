import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:page_transition/page_transition.dart';

class GridFilms extends StatelessWidget {
  const GridFilms({
    super.key,
    required this.posters,
    this.isPopToBottomNavScreen = false,
  });

  final List<dynamic> posters;
  final bool isPopToBottomNavScreen;

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
        (index) => GestureDetector(
          onTap: () {
            isPopToBottomNavScreen
                ? Navigator.of(context).pushAndRemoveUntil(
                    PageTransition(
                      child: FilmDetail(
                        filmId: posters[index]['film']['id'],
                      ),
                      type: PageTransitionType.rightToLeft,
                      duration: 300.ms,
                      reverseDuration: 300.ms,
                    ),
                    (route) => route.settings.name == '/bottom_nav',
                  )
                : Navigator.of(context).push(
                    PageTransition(
                      child: FilmDetail(
                        filmId: posters[index]['film']['id'],
                      ),
                      type: PageTransitionType.rightToLeft,
                      duration: 300.ms,
                      reverseDuration: 300.ms,
                    ),
                  );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://image.tmdb.org/t/p/w440_and_h660_face${posters[index]['film']['poster_path']}',
            ),
          ),
        ),
      ),
    );
  }
}
