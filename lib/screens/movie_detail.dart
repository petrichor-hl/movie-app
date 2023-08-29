import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/main.dart';

class MovieDeital extends StatefulWidget {
  const MovieDeital({super.key});

  @override
  State<MovieDeital> createState() => _MovieDeitalState();
}

class _MovieDeitalState extends State<MovieDeital> {
  Map<String, dynamic>? movie;
  late final _futureMovie = _fetchMovie();

  Future<void> _fetchMovie() async {
    final http.Response response;
    int randomMovieId = Random().nextInt(600);
    // print('movieId = $randomMovieId');
    try {
      final Uri uri =
          Uri.https('api.themoviedb.org', '/3/movie/$randomMovieId', {
        'api_key': tmdbApiKey,
        'language': 'vi-VN',
      });
      response = await http.get(uri);
    } catch (error) {
      // print('Error in try catch');
      return;
    }

    if (response.statusCode >= 400 || response.body == 'null') {
      throw Exception('404 Not Found');
    }

    movie = json.decode(response.body);
  }

  bool _isExpandOverview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureMovie,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final textPainter = TextPainter(
            text: TextSpan(
                text: movie == null ? '' : movie!['overview'],
                style: const TextStyle(color: Colors.white)),
            maxLines: 2,
            textDirection: TextDirection.ltr,
          )..layout(minWidth: 0, maxWidth: MediaQuery.sizeOf(context).width);

          final isOverflowed = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                'https://image.tmdb.org/t/p/original/${movie!['backdrop_path']}',
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Text(
                movie!['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Phát'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Phát'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: const Color.fromARGB(36, 255, 255, 255),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              RichText(
                text: TextSpan(
                  text: movie!['overview'],
                  style: GoogleFonts.montserrat().copyWith(color: Colors.white),
                ),
                maxLines: _isExpandOverview ? null : 4,
                textAlign: TextAlign.justify,
              ),
              if (isOverflowed)
                InkWell(
                  onTap: () => setState(() {
                    _isExpandOverview = !_isExpandOverview;
                  }),
                  child: Text(
                    _isExpandOverview ? 'Ẩn bớt' : 'Xem thêm',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
