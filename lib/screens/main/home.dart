import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/appbar/app_bar_cubit.dart';

import 'package:movie_app/data/topics_data.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/films_by_genre.dart';
import 'package:movie_app/widgets/content_header.dart';
import 'package:movie_app/widgets/content_list.dart';
import 'package:movie_app/widgets/custom_app_bar.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Size _screenSize = MediaQuery.sizeOf(context);

  late final ScrollController _scrollController = ScrollController()
    ..addListener(() {
      context.read<AppBarCubit>().setOffset(_scrollController.offset);
    });

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<dynamic> genres;

  late final _futureGenres = _fetchGenres();

  Future<void> _fetchGenres() async {
    genres = await supabase.from('genre').select();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(_screenSize.width, 70),
        child: BlocBuilder<AppBarCubit, double>(
          builder: (ctx, scrollOffset) {
            return CustomAppBar(
              scrollOffset: scrollOffset,
              scaffoldKey: _scaffoldKey,
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      // Thay đổi màu cho phần còn lại của màn hình khi Drawer đang mở
      // drawerScrimColor: Colors.transparent,
      endDrawer: buildEndDrawer(),
      // Tùy chọn: Khoảng cách bên phải để mở drawer khi vuốt từ lề
      drawerEdgeDragWidth: 40,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(
            child: ContentHeader(
              id: 'placeholder',
              posterPath: 'placeholder',
            ),
          ),
          // const SliverToBoxAdapter(
          //   child: Previews(
          //     key: PageStorageKey('previews'),
          //     title: 'Previews',
          //     contentList: previews,
          //   ),
          // ),
          ...topicsData.map(
            (row) => SliverToBoxAdapter(
              child: ContentList(
                key: PageStorageKey(topicsData[0]['name']),
                title: row['name'],
                films: row['films'],
                isOriginals: row['name'] == 'Chỉ có trên Netflix',
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    );
  }

  Widget buildEndDrawer() => Stack(
        children: [
          const SizedBox.expand(),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Drawer(
              width: 258,
              backgroundColor: Colors.black,
              elevation: 0,
              child: FutureBuilder(
                future: _futureGenres,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Truy xuất danh sách Thể loại thất bại',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return SafeArea(
                    child: ListView(
                      children: List.generate(
                        genres.length,
                        (index) => ListTile(
                          onTap: () => Navigator.of(context).push(
                            PageTransition(
                              child: ListFilmsByGenre(
                                genreId: genres[index]['id'],
                                genreName: genres[index]['name'],
                              ),
                              type: PageTransitionType.fade,
                            ),
                          ),
                          title: Text(
                            genres[index]['name'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 228,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton.filled(
                onPressed: () => _scaffoldKey.currentState!.closeEndDrawer(),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 32,
                ),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(14)),
              ),
            ),
          ),
        ],
      );
}
