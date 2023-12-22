import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/models/season.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/widgets/film_detail/episode_ui.dart';

class ListEpisodes extends StatefulWidget {
  const ListEpisodes(
    this.filmId,
    this.seasons, {
    super.key,
  });

  final String filmId;
  final List<Season> seasons;

  @override
  State<ListEpisodes> createState() => _ListEpisodesState();
}

class _ListEpisodesState extends State<ListEpisodes> {
  int selectedSeason = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton(
            value: selectedSeason,
            dropdownColor: const Color.fromARGB(255, 33, 33, 33),
            style: GoogleFonts.montserrat(fontSize: 16),
            isDense: true,
            items: List.generate(
              widget.seasons.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(
                  widget.seasons[index].name,
                ),
              ),
            ),
            onChanged: (value) {
              if (value != null && value != selectedSeason) {
                setState(() {
                  selectedSeason = value;
                });
                offlineData['season_id'] = widget.seasons[value].seasonId;
                offlineData['season_name'] = widget.seasons[value].name;
                // print('offine_data = $offlineData');
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        ...(widget.seasons[selectedSeason].episodes).map(
          (e) {
            // print('episode_id = ${e['id']}');
            return EpisodeUI(
              key: ValueKey(e.episodeId),
              episode: e,
              // Truyen filmId vao de lam gi ?
              filmId: widget.filmId,
            );
          },
        ),
      ],
    );
  }
}
