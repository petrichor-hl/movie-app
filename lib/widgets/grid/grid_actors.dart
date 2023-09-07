import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/screens/person_detail.dart';
import 'package:page_transition/page_transition.dart';

class GridActors extends StatelessWidget {
  const GridActors({super.key, required this.castData});

  final List<dynamic> castData;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 264,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      children: List.generate(
        castData.length,
        (index) => GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageTransition(
                child: PersonDetail(
                  personId: castData[index]['person']['id'],
                ),
                type: PageTransitionType.rightToLeft,
                duration: 240.ms,
                reverseDuration: 240.ms,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
              border:
                  Border.all(color: const Color.fromARGB(40, 255, 255, 255)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    'https://www.themoviedb.org/t/p/w276_and_h350_face${castData[index]['person']['profile_path']}',
                    height: 155,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        castData[index]['person']['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        castData[index]['character'],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
