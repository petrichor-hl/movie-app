import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/dtos/review_film.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/screens/film_detail.dart';
import 'package:movie_app/utils/extension.dart';

class ReviewsBottomSheet extends StatefulWidget {
  const ReviewsBottomSheet({
    super.key,
    required this.reviews,
    required this.onReviewHasChanged,
  });

  final List<ReviewFilm> reviews;
  final void Function() onReviewHasChanged;

  @override
  State<ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<ReviewsBottomSheet> {
  /* _existing_rateIndex: cho biết người dùng hiện tại đã đánh giá, cho điểm bộ phim hay chưa */
  int _existingRateIndex = -1;
  int _rate = 5;

  final _reviewsListKey = GlobalKey<AnimatedListState>();
  bool _isProcessing = false;

  Future<void> pushReview() async {
    // print("_rate = $_rate");
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));
    // print({
    //   'user_id': supabase.auth.currentUser!.id,
    //   'star': _rate,
    //   'created_at': DateTime.now().toVnFormat(),
    //   'film_id': offlineData['film_id'],
    // });
    await supabase.from('review').upsert(
      {
        'user_id': supabase.auth.currentUser!.id,
        'star': _rate,
        'created_at': DateTime.now().toVnFormat(),
        'film_id': offlineData['film_id'],
      },
    );

    if (_existingRateIndex != -1) {
      /*
      Người này đã rate phim này trước đó rồi
      => Xoá rate cũ trước thêm rate mới vào
      */
      Widget deleteItem = buildReviewItem(_existingRateIndex);
      _reviewsListKey.currentState!.removeItem(
        _existingRateIndex,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: deleteItem,
          // Không được set trực tiếp buildReviewItem(_existingRateIndex) và thuộc tính child
        ),
        duration: const Duration(milliseconds: 500),
      );
      widget.reviews.removeAt(_existingRateIndex);
    }

    widget.reviews.insert(
      0,
      ReviewFilm(
        userId: supabase.auth.currentUser!.id,
        hoTen: profileData['full_name'],
        avatarUrl: profileData['avatar_url'],
        star: _rate,
        createAt: DateTime.now(),
      ),
    );

    _existingRateIndex = 0;

    /*
    Nếu widget.reviews.isEmpty thì _reviewsListKey.currentState == null
    */
    if (_reviewsListKey.currentState != null) {
      _reviewsListKey.currentState!.insertItem(
        0,
        duration: const Duration(milliseconds: 500),
      );
    }

    /*
    Thông báo cho Widget cha để cập nhật lại điểm số với đánh giá mới
    */
    widget.onReviewHasChanged();

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void initState() {
    for (var i = 0; i < widget.reviews.length; ++i) {
      // print('${element.hoTen} ${element.star}');
      final review = widget.reviews[i];
      if (review.userId == supabase.auth.currentUser!.id) {
        _existingRateIndex = i;
        _rate = review.star;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              child: widget.reviews.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Chưa có nhận xét nào'),
                          Text('Hãy là người đánh giá đầu tiên'),
                        ],
                      ),
                    )
                  : AnimatedList(
                      key: _reviewsListKey,
                      initialItemCount: widget.reviews.length,
                      itemBuilder: (ctx, index, animation) => SizeTransition(
                        sizeFactor: animation,
                        child: buildReviewItem(index),
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
                  child: SizedBox(
                    width: 47,
                    height: 47,
                    child: CachedNetworkImage(
                      imageUrl: '$baseAvatarUrl${profileData['avatar_url']}',
                      fit: BoxFit.cover,
                      // fadeInDuration: là thời gian xuất hiện của Image khi đã load xong
                      fadeInDuration: const Duration(milliseconds: 400),
                      // fadeOutDuration: là thời gian biến mất của placeholder khi Image khi đã load xong
                      fadeOutDuration: const Duration(milliseconds: 800),
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
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
                  onPressed: _isProcessing ? null : pushReview,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeCap: StrokeCap.round,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.arrow_upward_rounded),
                ),
                const Gap(12),
              ],
            ),
            if (Platform.isAndroid) const Gap(14)
          ],
        ),
      ),
    );
  }

  Widget buildReviewItem(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 44,
            height: 44,
            child: CachedNetworkImage(
              imageUrl: '$baseAvatarUrl${widget.reviews[index].avatarUrl}',
              fit: BoxFit.cover,
              // fadeInDuration: là thời gian xuất hiện của Image khi đã load xong
              fadeInDuration: const Duration(milliseconds: 400),
              // fadeOutDuration: là thời gian biến mất của placeholder khi Image khi đã load xong
              fadeOutDuration: const Duration(milliseconds: 800),
              placeholder: (context, url) => const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  strokeWidth: 3,
                ),
              ),
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
                setStateRate(() => _rate = index + 1);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  index + 1 <= _rate ? Icons.star_rounded : Icons.star_border_rounded,
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
