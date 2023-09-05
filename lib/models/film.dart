class Film {
  final String name;
  final DateTime releaseDate;
  final double voteAverage;
  final int voteCount;
  final String overview;
  final String backdropPath;
  final String posterPath;
  final String contentRating;
  final String trailer;

  const Film({
    required this.name,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.overview,
    required this.backdropPath,
    required this.posterPath,
    required this.contentRating,
    required this.trailer,
  });
}
