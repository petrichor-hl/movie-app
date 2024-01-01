import 'package:flutter/material.dart';
import 'package:movie_app/models/episode.dart';
import 'package:movie_app/models/season.dart';
import 'package:movie_app/widgets/video_player/horizontal_list_episodes.dart';
import 'package:video_player/video_player.dart';

class VideoBottomUtils extends StatefulWidget {
  const VideoBottomUtils({
    required this.overlayVisible,
    required this.videoPlayerController,
    required this.startCountdownToDismissControls,
    required this.cancelTimer,
    required this.lockControls,
    required this.currentEpisodeId,
    required this.seasons,
    required this.seasonIndex,
    required this.moveToEdpisode,
    super.key,
  });

  final bool overlayVisible;
  final VideoPlayerController videoPlayerController;
  final void Function() cancelTimer;
  final void Function() startCountdownToDismissControls;

  final void Function(bool) lockControls;

  final String currentEpisodeId;
  final List<Season> seasons;
  final int seasonIndex;

  final void Function(Episode, int) moveToEdpisode;

  @override
  State<VideoBottomUtils> createState() => _VideoBottomUtilsState();
}

class _VideoBottomUtilsState extends State<VideoBottomUtils> {
  /*
  NOTE:
  Ban đầu, tôi thiết lập VideoBottomUtils là StatelessWidget
  Nhưng, nhận thấy VideoBottomUtils sẽ build lại sau mỗi lần Ẩn/Hiện
  Do đó, sẽ làm mất đi currentSpeedOption 
  => Phải đổi VideoBottomUtils thành StatefulWidget
  currentSpeedOption sẽ không bị mất giá trị hiện tại sau mỗi lần Ẩn/Hiện nữa
  */
  final speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5];
  late double currentSpeedOption = speedOptions[2]; // Tốc độ 1x

  Map<String, dynamic>? findNextEpisode() {
    for (int i = 0; i < widget.seasons.length; ++i) {
      final episodes = widget.seasons[i].episodes;
      for (int j = 0; j < episodes.length; ++j) {
        if (episodes[j].episodeId == widget.currentEpisodeId) {
          if (i == widget.seasons.length - 1 && j == episodes.length - 1) {
            /*
            Tập cuối của Season cuối 
            => Không có tập tiếp theo
            */
            return null;
          }
          if (j == episodes.length - 1) {
            /*
            Tập cuối của Season thứ i
            => Tập tiếp theo là Tập 1 của Seaon thứ (i+1)
            */
            return {
              'episode': widget.seasons[i + 1].episodes[0],
              'season_index': i + 1,
            };
          }
          return {
            'episode': episodes[j + 1],
            'season_index': i,
          };
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // print("_VideoBottomUtilsState rebuild");
    final totalEpisodes = widget.seasons
        .fold(0, (previousValue, season) => previousValue + season.episodes.length);

    final nextEpisode = findNextEpisode();

    return SafeArea(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: widget.overlayVisible ? const Offset(0, 0) : const Offset(0, 1.2),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () async {
                widget.cancelTimer();
                await showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...speedOptions.map(
                              (speedOption) => RadioListTile(
                                title: Text('${speedOption}x'),
                                value: speedOption,
                                groupValue: currentSpeedOption,
                                onChanged: (value) {
                                  if (value != null) {
                                    print('speed = $value');
                                    currentSpeedOption = value;
                                    widget.videoPlayerController.setPlaybackSpeed(value);
                                    Navigator.of(context).pop();
                                  }
                                },
                                dense: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Huỷ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                widget.startCountdownToDismissControls();
              },
              icon: const Icon(Icons.speed_rounded),
              label: const Text('Tốc độ'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () => widget.lockControls(true),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Khoá'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            if (totalEpisodes != 1)
              TextButton.icon(
                onPressed: () async {
                  widget.cancelTimer();

                  widget.videoPlayerController.pause();
                  final Map<String, dynamic>? selectedEpisode =
                      await showModalBottomSheet(
                    context: context,
                    builder: (ctx) => HorizontalListEpisodes(
                      widget.seasons,
                      seasonsIndex: widget.seasonIndex,
                    ),
                    /*
                  Gỡ bỏ giới hạn của chiều cao của BottomSheet
                  */
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    shape: const RoundedRectangleBorder(),
                    backgroundColor: Colors.black,
                    isScrollControlled: true,
                  );
                  /*
                  selectedEpisode là Tập phim được người dùng chọn để xem
                  */
                  if (selectedEpisode == null) {
                    widget.videoPlayerController.play();
                    widget.startCountdownToDismissControls();
                  } else {
                    // Chuyển sang xem tập phim này
                    widget.moveToEdpisode(
                      selectedEpisode['episode'],
                      selectedEpisode['season_index'],
                    );
                  }
                },
                icon: const Icon(Icons.view_carousel_rounded),
                label: const Text('Các tập'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            if (nextEpisode != null)
              TextButton.icon(
                onPressed: () {
                  widget.moveToEdpisode(
                    nextEpisode['episode'],
                    nextEpisode['season_index'],
                  );
                },
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Tập tiếp theo'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
