import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:movie_app/models/content.dart';

class ContentHeader extends StatefulWidget {
  const ContentHeader({super.key, required this.featuredContent});

  final Content featuredContent;

  @override
  State<ContentHeader> createState() => _ContentHeaderState();
}

class _ContentHeaderState extends State<ContentHeader> {
  final List<String> _genres = [];

  late Future<void> _futureGenres;

  Future<void> _loadContentHeader() async {
    final http.Response response;
    int randomMovieId = Random().nextInt(600);
    // print(randomMovieId);
    try {
      final Uri uri =
          Uri.https('api.themoviedb.org', '/3/movie/$randomMovieId', {
        'api_key': 'a29284b32c092cc59805c9f5513d3811',
        'language': 'vi-VN',
      });
      response = await http.get(uri);
    } catch (error) {
      return;
    }

    if (response.statusCode >= 400 || response.body == 'null') {
      return;
    }

    final Map<String, dynamic> fetchedData = json.decode(response.body);
    for (final genreItem in fetchedData['genres']) {
      String genre = genreItem['name'];
      _genres.add(
        genre.replaceFirst('Phim ', ''),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _futureGenres = _loadContentHeader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureGenres,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 500,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 500,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.featuredContent.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 500,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 250,
                    child: Image.asset(widget.featuredContent.titleImageUrl),
                  ),
                  if (_genres.isNotEmpty)
                    const SizedBox(
                      height: 8,
                    ),
                  if (_genres.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _genres[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        for (int i = 1; i < min(3, _genres.length); ++i)
                          Text(
                            ' - ${_genres[i]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 30,
                          ),
                          label: const Text(
                            'Phát',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Danh sách'),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
