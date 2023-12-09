import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/dtos/review_film.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/utils/extension.dart';

class ReviewsBottomSheet extends StatefulWidget {
  const ReviewsBottomSheet({super.key, required this.reviews});

  final List<ReviewFilm> reviews;

  @override
  State<ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<ReviewsBottomSheet> {
  bool isProcessing = false;
  int rate = 5;

  @override
  Widget build(BuildContext context) {
    for (var element in widget.reviews) {
      // print('${element.hoTen} ${element.star}');
      if (element.userId == supabase.auth.currentUser!.id) {
        rate = element.star;
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(21, 5, 5, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  "ĐÁNH GIÁ   ●   ${widget.reviews.length} lượt",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              ],
            ),
            const Gap(4),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.35,
              child: ListView(
                children: List.generate(
                  widget.reviews.length,
                  (index) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 44,
                          child: Image.network(
                            widget.reviews[index].avatarUrl,
                          ),
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.reviews[index].hoTen,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${widget.reviews[index].star} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.star_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const Spacer(),
                                Text(
                                  widget.reviews[index].createAt.toVnFormat(),
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const Gap(20)
                          ],
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Divider(),
            ),
            const Gap(4),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    profileData['avatar_url'],
                    height: 47,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileData['full_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      buildStarRate(),
                    ],
                  ),
                ),
                const Gap(14),
                IconButton.filled(
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                const Gap(12),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildStarRate() {
    return StatefulBuilder(
      builder: (ctx, setStateRate) {
        return Row(
          children: List.generate(
            5,
            (index) => InkWell(
              onTap: () {
                setStateRate(() => rate = index + 1);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  index + 1 <= rate ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
