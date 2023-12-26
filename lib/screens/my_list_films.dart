import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/models/poster.dart';
import 'package:movie_app/widgets/grid/grid_films.dart';
import 'package:shimmer/shimmer.dart';

class MyListFilms extends StatefulWidget {
  const MyListFilms({
    super.key,
  });

  @override
  State<MyListFilms> createState() => _MyListFilmsState();
}

class _MyListFilmsState extends State<MyListFilms> {
  final List<Poster> _postersData = [];

  Future<void> _fetchMyListFilms() async {
    _postersData.clear();

    final filmIds = context.watch<MyListCubit>().state;

    for (final filmId in filmIds) {
      final Map<String, dynamic> posterData =
          await supabase.from('film').select('poster_path').eq('id', filmId).single();

      _postersData.add(
        Poster(
          filmId: filmId,
          posterPath: posterData['poster_path'],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<RouteStackCubit>().pop();
        context.read<RouteStackCubit>().printRouteStack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Danh sách của tôi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder(
          future: _fetchMyListFilms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                  context.watch<MyListCubit>().state.length,
                  (index) => Shimmer.fromColors(
                    baseColor: Colors.white.withAlpha(100),
                    highlightColor: Colors.grey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ColoredBox(
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Wrap GridFilms trong SizedBox.expand() vì
            // GridFilms được thiết lập để dài ra theo những con trong nó thôi (shrinkWrap: true,)
            // Nên hiệu ứng slideY bắt đầu từ 0.3 sẽ không được đồng đều
            // Thể thoại này có ít phim thể loại kia có nhiều phim nên height của GridFilms là khác nhau
            return _postersData.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_search,
                          color: Colors.grey,
                          size: 64,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'Bạn chưa thêm thêm phim nào vào Danh sách',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.expand(
                    child: SingleChildScrollView(
                      child: GridFilms(
                        posters: _postersData,
                      ),
                    ),
                  ).animate().fadeIn(
                      begin: 0.5,
                      curve: Curves.easeInOut,
                    );
          },
        ),
      ),
    );
  }
}
