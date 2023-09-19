import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/my_list_films.dart';
import 'package:page_transition/page_transition.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.filmId,
  });

  final String filmId;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool isInMyList = context.read<MyListCubit>().contain(widget.filmId);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          final userId = supabase.auth.currentUser!.id;
          final currentMyList = context.read<MyListCubit>().state;
          // print('user_id: $userId');
          // print('new_list: ${[...currentMyList, widget.filmId]}');
          await supabase.from('profiles').update({
            'my_list': [...currentMyList, widget.filmId],
          }).eq('id', userId);
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Có lỗi xảy ra! Vui lòng thử lại sau'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        if (mounted) {
          isInMyList
              ? context.read<MyListCubit>().removeFilms(widget.filmId)
              : context.read<MyListCubit>().addFilms(widget.filmId);
          setState(() {
            isInMyList = !isInMyList;
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: isInMyList
                  ? const Text('Đã thêm vào Danh sách của tôi')
                  : const Text('Đã xoá vào Danh sách của tôi'),
              duration: const Duration(seconds: 3),
              action: isInMyList
                  ? SnackBarAction(
                      label: 'Xem',
                      onPressed: () {
                        Navigator.of(context).push(
                          PageTransition(
                            child: const MyListFilms(),
                            type: PageTransitionType.size,
                            alignment: Alignment.bottomCenter,
                          ),
                        );
                      },
                    )
                  : null,
            ),
          );
        }
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
