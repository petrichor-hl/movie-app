// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/my_list_films.dart';
import 'package:page_transition/page_transition.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isInMyList,
    required this.filmId,
  });

  final String filmId;
  final bool isInMyList;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          final userId = supabase.auth.currentUser!.id;
          final currentMyList = context.read<MyListCubit>().state;
          // print('user_id: $userId');
          // print('new_list: ${[...currentMyList, filmId]}');
          await supabase.from('profile').update({
            'my_list': isInMyList
                ? currentMyList.where((element) => element != filmId).toList()
                : [...currentMyList, filmId],
          }).eq('id', userId);
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra! Vui lòng thử lại sau'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        isInMyList
            ? context.read<MyListCubit>().removeFilms(filmId)
            : context.read<MyListCubit>().addFilms(filmId);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: isInMyList
                ? const Text('Đã xoá vào Danh sách của tôi')
                : const Text('Đã thêm vào Danh sách của tôi'),
            duration: const Duration(seconds: 3),
            action: isInMyList
                ? null
                : SnackBarAction(
                    label: 'Xem',
                    onPressed: () {
                      context.read<RouteStackCubit>().push('/my_list_films');
                      context.read<RouteStackCubit>().printRouteStack();
                      Navigator.of(context).push(
                        PageTransition(
                          child: const MyListFilms(),
                          type: PageTransitionType.size,
                          alignment: Alignment.bottomCenter,
                          settings: const RouteSettings(name: '/my_list_films'),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.5, end: 1).animate(animation),
          child: child,
        ),
        child: Icon(
          isInMyList ? Icons.star : Icons.star_outline,
          key: ValueKey(isInMyList),
        ),
      ),
    );
  }
}
