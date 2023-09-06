import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/screens/movie_detail.dart';
import 'package:page_transition/page_transition.dart';

class ContentList extends StatelessWidget {
  const ContentList({
    super.key,
    required this.title,
    required this.films,
    this.isOriginals = false,
  });

  final String title;
  final List<dynamic> films;
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
                onTap: () {
                  Navigator.of(context).push(
                    PageTransition(
                        child: MovieDeital(filmId: film['id']),
                        type: PageTransitionType.rightToLeft,
                        duration: 300.ms,
                        reverseDuration: 300.ms),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: isOriginals ? 240 : 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                        isOriginals
                            ? 'https://image.tmdb.org/t/p/w600_and_h900_bestv2${film['poster_path']}'
                            : 'https://image.tmdb.org/t/p/w440_and_h660_face${film['poster_path']}',
                      ),
                      fit: BoxFit.cover,
                    ),
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
