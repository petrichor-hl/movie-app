import 'package:flutter/material.dart';
import 'package:movie_app/models/content.dart';
import 'package:movie_app/screens/movie_detail.dart';

class ContentList extends StatelessWidget {
  const ContentList({
    super.key,
    required this.title,
    required this.contentList,
    this.isOriginals = false,
  });

  final String title;
  final List<Content> contentList;
  final bool isOriginals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: isOriginals ? 500 : 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final content = contentList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const MovieDeital(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: isOriginals ? 400 : 200,
                  width: isOriginals ? 200 : 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: AssetImage(content.imageUrl), fit: BoxFit.cover),
                  ),
                ),
              );
            },
            itemCount: contentList.length,
          ),
        )
      ],
    );
  }
}
