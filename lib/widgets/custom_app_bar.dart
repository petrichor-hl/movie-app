import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/assets.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/screens/main/search_film.dart';
import 'package:page_transition/page_transition.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.scrollOffset = 0,
    required this.scaffoldKey,
  });

  final double scrollOffset;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(
        (scrollOffset / 350).clamp(0, 1).toDouble(),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SafeArea(
        child: Row(
          children: [
            Image.asset(Assets.viovidSymbol),
            const Gap(8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AppBarButton('TV Shows', scrollOffset, () {}),
                  _AppBarButton('Phim', scrollOffset, () {}),
                  _AppBarButton('Thể loại', scrollOffset,
                      () => scaffoldKey.currentState!.openEndDrawer()),
                  IconButton(
                    onPressed: () {
                      context.read<RouteStackCubit>().push('/search_film_screen');
                      context.read<RouteStackCubit>().printRouteStack();
                      Navigator.of(context).push(
                        PageTransition(
                          child: const SearchFilmScreen(),
                          type: PageTransitionType.rightToLeft,
                          duration: 300.ms,
                          reverseDuration: 300.ms,
                          settings: const RouteSettings(name: '/search_film_screen'),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(foregroundColor: Colors.white),
                    icon: const Icon(
                      Icons.search_rounded,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  const _AppBarButton(this.text, this.scrollOffset, this.onTap);

  final String text;
  final double scrollOffset;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
