import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
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
              String? prior = context
                  .read<RouteStackCubit>()
                  .findPrior('/person_detail@${personsData[index]['person']['id']}');
              /*
              prior là route trước của /person_detail@${personsData[index]['person']['id']}
              nếu /person_detail@${personsData[index]['person']['id']} có trong RouteStack
              */
              if (prior != null) {
                // Trong Stack đã từng di chuyển tới Person này rồi
                Navigator.of(context).pushAndRemoveUntil(
                  PageTransition(
                    child: PersonDetail(
                      personId: personsData[index]['person']['id'],
                      isCast: isCast,
                    ),
                    type: PageTransitionType.rightToLeft,
                    duration: 240.ms,
                    reverseDuration: 240.ms,
                    settings: RouteSettings(
                        name: '/person_detail@${personsData[index]['person']['id']}'),
                  ),
                  (route) {
                    if (route.settings.name == prior) {
                      /*
                      Khi đã gặp prior route của /person_detail@${personsData[index]['person']['id']}
                      Thì push /person_detail@${personsData[index]['person']['id']} vào Stack
                      */
                      context
                          .read<RouteStackCubit>()
                          .push('/person_detail@${personsData[index]['person']['id']}');
                      context.read<RouteStackCubit>().printRouteStack();
                      return true;
                    } else {
                      context.read<RouteStackCubit>().pop();
                      return false;
                    }
                  },
                );
              } else {
                // Chưa từng di chuyển tới Person này
                context
                    .read<RouteStackCubit>()
                    .push('/person_detail@${personsData[index]['person']['id']}');
                context.read<RouteStackCubit>().printRouteStack();
                Navigator.of(context).push(
                  PageTransition(
                    child: PersonDetail(
                      personId: personsData[index]['person']['id'],
                      isCast: isCast,
                    ),
                    type: PageTransitionType.rightToLeft,
                    duration: 240.ms,
                    reverseDuration: 240.ms,
                    settings: RouteSettings(
                        name: '/person_detail@${personsData[index]['person']['id']}'),
                  ),
                );
              }
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
                            'https://www.themoviedb.org/t/p/w276_and_h350_face/${personsData[index]['person']['profile_path']}',
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
