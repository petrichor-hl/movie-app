import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/models/poster.dart';
import 'package:movie_app/widgets/grid/grid_films.dart';
import 'package:shimmer/shimmer.dart';

class FilmsByGenre extends StatefulWidget {
  const FilmsByGenre({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  final String genreId;
  final String genreName;

  @override
  State<FilmsByGenre> createState() => _FilmsByGenreState();
}

class _FilmsByGenreState extends State<FilmsByGenre> {
  final List<Poster> _posters = [];
  late final _futureFilms = _fetchFilmsOnDemand();

  Future<void> _fetchFilmsOnDemand() async {
    final List<dynamic> postersData = await supabase
        .from('film_genre')
        .select('film(id, poster_path)')
        .eq('genre_id', widget.genreId);

    for (var element in postersData) {
      _posters.add(
        Poster(
          filmId: element['film']['id'],
          posterPath: element['film']['poster_path'],
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
          title: Text(
            widget.genreName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder(
          future: _futureFilms,
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
                  12,
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
            return SizedBox.expand(
              child: SingleChildScrollView(
                child: GridFilms(
                  posters: _posters,
                ),
              ),
            );
            // ).animate().slideY(
            //       begin: 0.3,
            //       end: 0,
            //       curve: Curves.easeInOut,
            //     );
          },
        ),
      ),
    );
  }
}
