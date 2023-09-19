import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/my_list/my_list_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/widgets/grid/grid_films.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyListFilms extends StatefulWidget {
  const MyListFilms({
    super.key,
  });

  @override
  State<MyListFilms> createState() => _MyListFilmsState();
}

class _MyListFilmsState extends State<MyListFilms> {
  final List<dynamic> _postersData = [];
  late final _futureMyListFilms = _fetchMyListFilms();

  Future<void> _fetchMyListFilms() async {
    final filmIds = context.read<MyListCubit>().state;
    for (final filmId in filmIds) {
      final Map<String, dynamic> posterPath =
          await supabase.from('film').select('poster_path').eq('id', filmId).single();

      posterPath.addAll({'id': filmId});
      _postersData.add({
        'film': posterPath,
      });
    }

    // await Future.delayed(
    //   const Duration(seconds: 1),
    // );
  }

  @override
  void initState() {
    super.initState();
    supabase.channel('update_my_list').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'update', schema: 'public', table: 'profiles'),
      (payload, [ref]) async {
        final newMyList = payload['new']['my_list'];
        print('new_my_list = $newMyList');
      },
    ).subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        future: _futureMyListFilms,
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
                ).animate().slideY(
                    begin: 0.3,
                    end: 0,
                    curve: Curves.easeInOut,
                  );
        },
      ),
    );
  }
}
