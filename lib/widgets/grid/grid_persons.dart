import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/screens/person_detail.dart';
import 'package:page_transition/page_transition.dart';

class GridPersons extends StatelessWidget {
  const GridPersons({
    super.key,
    required this.personsData,
    this.isCast = true,
  });

  final List<dynamic> personsData;
  final bool isCast;

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
        personsData.length,
        (index) {
          final profilePath = personsData[index]['person']['profile_path'];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  child: PersonDetail(
                    personId: personsData[index]['person']['id'],
                    isCast: isCast,
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
                border: Border.all(color: const Color.fromARGB(40, 255, 255, 255)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profilePath == null
                      ? SizedBox(
                          height: 155,
                          child: Center(
                            child: Icon(
                              personsData[index]['person']['gender'] == 0
                                  ? Icons.person_rounded
                                  : Icons.person_3_rounded,
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                            'https://www.themoviedb.org/t/p/w276_and_h350_face${personsData[index]['person']['profile_path']}',
                            width: double.infinity, // minus border's width = 1
                            height: 155,
                            fit: BoxFit.cover,
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          personsData[index]['person']['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          personsData[index]['role'],
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
          );
        },
      ),
    );
  }
}
