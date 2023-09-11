import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/widgets/film_detail/grid_shimmer.dart';
import 'package:movie_app/widgets/film_detail/list_episodes.dart';
import 'package:movie_app/widgets/grid/grid_persons.dart';

class SegmentCompose extends StatefulWidget {
  const SegmentCompose(this.seasons, this.isMovie, this.filmId, {super.key});

  final List<dynamic> seasons;
  final bool isMovie;
  final String filmId;

  @override
  State<SegmentCompose> createState() => _SegmentComposeState();
}

class _SegmentComposeState extends State<SegmentCompose> {
  late int _segmentIndex = widget.isMovie ? 1 : 0;
  late final _listEpisodes = ListEpisodes(widget.seasons);
  final _gridShimmer = const GridShimmer();

  late final List<dynamic> _castData;
  late final _futureCastData = _fetchCastData();

  late final List<dynamic> _crewData;
  late final _futureCrewData = _fetchCrewData();

  Future<void> _fetchCastData() async {
    _castData = await supabase
        .from('cast')
        .select('role: character, person(id, name, profile_path, popularity)')
        .eq('film_id', widget.filmId);

    _castData.sort((a, b) =>
        b['person']['popularity'].compareTo(a['person']['popularity']));
  }

  Future<void> _fetchCrewData() async {
    _crewData = await supabase
        .from('crew')
        .select('role: job, person(id, name, profile_path, popularity, gender)')
        .eq('film_id', widget.filmId);

    _crewData.sort((a, b) =>
        b['person']['popularity'].compareTo(a['person']['popularity']));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: CupertinoSlidingSegmentedControl(
            backgroundColor: Colors.white.withAlpha(36),
            thumbColor: Colors.black,
            groupValue: _segmentIndex,
            children: widget.isMovie
                ? {
                    1: buildSegment('Đề xuất'),
                    2: buildSegment('Diễn viên'),
                    3: buildSegment('Đội ngũ'),
                  }
                : {
                    0: buildSegment('Tập phim'),
                    1: buildSegment('Đề xuất'),
                    2: buildSegment('Diễn viên'),
                    3: buildSegment('Đội ngũ'),
                  },
            onValueChanged: (index) {
              setState(() {
                _segmentIndex = index!;
              });
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: switch (_segmentIndex) {
            0 => _listEpisodes,
            2 => FutureBuilder(
                future: _futureCastData,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _gridShimmer;
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      'Truy xuất thông tin Diễn viên thất bại',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    );
                  }

                  return GridPersons(personsData: _castData);
                },
              ),
            3 => FutureBuilder(
                future: _futureCrewData,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _gridShimmer;
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      'Truy xuất thông tin Đội ngũ thất bại',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    );
                  }

                  return GridPersons(
                    personsData: _crewData,
                    isCast: false,
                  );
                },
              ),
            _ => null,
          },
        ),
      ],
    );
  }

  Widget buildSegment(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
