import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/cubits/video_play_control/video_play_control_cubit.dart';
import 'package:movie_app/cubits/video_slider/video_slider_cubit.dart';
import 'package:movie_app/models/season.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/widgets/film_detail/episode_ui_first.dart';
import 'package:movie_app/widgets/video_player/video_player_view.dart';

class ListEpisodes extends StatefulWidget {
  const ListEpisodes(
    this.seasons,
    this.downloadedEpisodeIds, {
    super.key,
  });

  final List<Season> seasons;
  final List<String> downloadedEpisodeIds;

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
            return EpisodeUIFirst(
              key: ValueKey(e.episodeId),
              episode: e,
              isEpisodeDownloaded: widget.downloadedEpisodeIds.contains(e.episodeId),
              watchEpisode: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (ctx) => VideoSliderCubit(),
                        ),
                        BlocProvider(
                          create: (ctx) => VideoPlayControlCubit(),
                        ),
                      ],
                      child: VideoPlayerView(
                        filmId: offlineData['film_id'],
                        seasons: widget.seasons,
                        downloadedEpisodeIds: widget.downloadedEpisodeIds,
                        firstEpisodeToPlay: e,
                        firstSeasonIndex: selectedSeason,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
