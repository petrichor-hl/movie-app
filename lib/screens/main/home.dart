import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/appbar/app_bar_cubit.dart';

import 'package:movie_app/data/poster_data.dart';
import 'package:movie_app/widgets/export_widgets.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(_screenSize.width, 70),
        child: BlocBuilder<AppBarCubit, double>(
          builder: (ctx, scrollOffset) {
            return CustomAppBar(
              scrollOffset: scrollOffset,
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
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
          ...posterData.map(
            (row) => SliverToBoxAdapter(
              child: ContentList(
                key: PageStorageKey(posterData[0]['name']),
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
}
