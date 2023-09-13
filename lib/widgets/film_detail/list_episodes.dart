import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/widgets/film_detail/episode.dart';

class ListEpisodes extends StatefulWidget {
  const ListEpisodes(this.seasons, {super.key});

  final List<dynamic> seasons;

  @override
  State<ListEpisodes> createState() => __ListEpisodesState();
}

class __ListEpisodesState extends State<ListEpisodes> {
  int selectedSeason = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton(
          value: selectedSeason,
          dropdownColor: const Color.fromARGB(255, 33, 33, 33),
          style: GoogleFonts.montserrat(fontSize: 16),
          isDense: true,
          items: List.generate(
            widget.seasons.length,
            (index) => DropdownMenuItem(
              value: index,
              child: Text(
                widget.seasons[index]['name'],
              ),
            ),
          ),
          onChanged: (value) {
            if (value != null && value != selectedSeason) {
              setState(() {
                selectedSeason = value;
              });
              offlineData['season_id'] = widget.seasons[value]['id'];
              offlineData['season_name'] = widget.seasons[value]['name'];
              // print('offine_data = $offlineData');
            }
          },
        ),
        const SizedBox(height: 12),
        ...(widget.seasons[selectedSeason]['episode'] as List<dynamic>).map(
          (e) {
            // print('episode_id = ${e['id']}');
            return Episode(
              e['id'],
              e['order'],
              e['still_path'],
              e['title'],
              e['runtime'],
              e['subtitle'],
              e['link'],
              key: ValueKey(e['id']),
            );
          },
        ),
      ],
    );
  }
}
