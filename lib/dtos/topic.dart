import 'package:movie_app/models/poster.dart';

class Topic {
  String name;
  List<Poster> posters;

  Topic({
    required this.name,
    required this.posters,
  });
}
