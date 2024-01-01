import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/cubits/route_stack/route_stack_cubit.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/widgets/skeleton_loading.dart';
import 'package:page_transition/page_transition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<dynamic>? _notificationFilms;

class NewHotScreen extends StatefulWidget {
  const NewHotScreen({super.key});

  @override
  State<NewHotScreen> createState() => _NewHotScreenState();
}

class _NewHotScreenState extends State<NewHotScreen> {
  final _notificationListKey = GlobalKey<AnimatedListState>();

  late final _futureNotificationNewFilms = _fetchNotificationNewFilms();

  Future<void> _fetchNotificationNewFilms() async {
    _notificationFilms = await supabase
        .from('notification')
        .select('created_at, film(id, name, backdrop_path, overview, content_rating)')
        .order('created_at', ascending: false);
  }

  late final _listNotification = AnimatedList(
    key: _notificationListKey,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    initialItemCount: _notificationFilms!.length,
    itemBuilder: (ctx, index, animation) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: const Offset(0, 0),
        ).animate(animation),
        child: NotificationNewFilm(
          uploadDate: _notificationFilms![index]['created_at'],
          id: _notificationFilms![index]['film']['id'],
          name: _notificationFilms![index]['film']['name'],
          backdropPath: _notificationFilms![index]['film']['backdrop_path'],
          overview: _notificationFilms![index]['film']['overview'],
          contentRating: _notificationFilms![index]['film']['content_rating'],
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    // supabase.channel('delete').on(
    //   RealtimeListenTypes.postgresChanges,
    //   ChannelFilter(event: 'delete', schema: 'public', table: 'notification'),
    //   (payload, [ref]) async {
    //     final removedItemId = payload['old']['created_at'];
    //     final index = _notificationFilms!.indexWhere(
    //       (element) => element['created_at'] == removedItemId,
    //     );

    //     final deleteItem = NotificationNewFilm(
    //       uploadDate: _notificationFilms![index]['created_at'],
    //       id: _notificationFilms![index]['film']['id'],
    //       name: _notificationFilms![index]['film']['name'],
    //       backdropPath: _notificationFilms![index]['film']['backdrop_path'],
    //       overview: _notificationFilms![index]['film']['overview'],
    //       contentRating: _notificationFilms![index]['film']['content_rating'],
    //     );

    //     _notificationListKey.currentState!.removeItem(
    //       index,
    //       // animation
    //       (ctx, animation) => SizeTransition(
    //         sizeFactor: animation,
    //         child: deleteItem,
    //       ),
    //       duration: const Duration(milliseconds: 300),
    //     );

    //     // remove underlying data
    //     _notificationFilms!.removeAt(index);
    //   },
    // ).subscribe();
    supabase
        .channel('insert_notification')
        .onPostgresChanges(
          schema: 'public',
          table: 'notification',
          event: PostgresChangeEvent.insert,
          callback: (payload) async {
            final newNotificationFilm = await supabase
                .from('film')
                .select('id, name, backdrop_path, overview, content_rating')
                .eq('id', payload.newRecord['film_id'])
                .single();

            // insert underlying data
            _notificationFilms!.insert(
              0,
              {
                'created_at': payload.newRecord['created_at'],
                'film': newNotificationFilm,
              },
            );

            _notificationListKey.currentState!.insertItem(
              0,
              duration: const Duration(milliseconds: 300),
            );
          },
        )
        .subscribe();

    supabase
        .channel('delete_notification')
        .onPostgresChanges(
          schema: 'public',
          table: 'notification',
          event: PostgresChangeEvent.delete,
          callback: (payload) async {
            final removedItemId = payload.oldRecord['created_at'];
            final index = _notificationFilms!.indexWhere(
              (element) => element['created_at'] == removedItemId,
            );

            final deleteItem = NotificationNewFilm(
              uploadDate: _notificationFilms![index]['created_at'],
              id: _notificationFilms![index]['film']['id'],
              name: _notificationFilms![index]['film']['name'],
              backdropPath: _notificationFilms![index]['film']['backdrop_path'],
              overview: _notificationFilms![index]['film']['overview'],
              contentRating: _notificationFilms![index]['film']['content_rating'],
            );

            _notificationListKey.currentState!.removeItem(
              index,
              // animation
              (ctx, animation) => SizeTransition(
                sizeFactor: animation,
                child: deleteItem,
              ),
              duration: const Duration(milliseconds: 300),
            );

            // remove underlying data
            _notificationFilms!.removeAt(index);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mới ra mắt',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: _notificationFilms == null
          ? FutureBuilder(
              future: _futureNotificationNewFilms,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildSkeletonLoading();
                }
                return _listNotification;
              },
            )
          : _listNotification,
    );
  }

  Widget buildSkeletonLoading() {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoading(height: 71, width: 49),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoading(height: 174, width: double.infinity),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonLoading(height: 29, width: double.infinity),
                        ),
                        SizedBox(width: 20),
                        SkeletonLoading(height: 29, width: 32),
                      ],
                    ),
                    SizedBox(height: 8),
                    SkeletonLoading(height: 80, width: double.infinity),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoading(height: 71, width: 49),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoading(height: 174, width: double.infinity),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonLoading(height: 29, width: double.infinity),
                        ),
                        SizedBox(width: 20),
                        SkeletonLoading(height: 29, width: 32),
                      ],
                    ),
                    SizedBox(height: 8),
                    SkeletonLoading(height: 80, width: double.infinity),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class NotificationNewFilm extends StatelessWidget {
  const NotificationNewFilm({
    super.key,
    required this.uploadDate,
    required this.id,
    required this.name,
    required this.backdropPath,
    required this.overview,
    required this.contentRating,
  });

  final String uploadDate;
  final String id;
  final String name;
  final String backdropPath;
  final String overview;
  final String contentRating;

  @override
  Widget build(BuildContext context) {
    DateTime uploadDateTime = DateTime.parse(uploadDate);
    String date = uploadDateTime.day.toString().padLeft(2, '0');
    String month = 'THG ${uploadDateTime.month}';

    double screenWidth = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 0.5625 * (screenWidth - 20 - 60 - 10),
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/original/$backdropPath',
                        fit: BoxFit.cover,
                        // fadeInDuration: là thời gian xuất hiện của Image khi đã load xong
                        fadeInDuration: const Duration(milliseconds: 500),
                        // fadeOutDuration: là thời gian biến mất của placeholder khi Image khi đã load xong
                        fadeOutDuration: const Duration(milliseconds: 1000),
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.black,
                          ),
                          child: Text(
                            contentRating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        context.read<RouteStackCubit>().push('/film_detail@$id');
                        context.read<RouteStackCubit>().printRouteStack();
                        Navigator.of(context).push(
                          PageTransition(
                            child: FilmDetail(filmId: id),
                            type: PageTransitionType.fade,
                            settings: RouteSettings(name: '/film_detail@$id'),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  overview,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
