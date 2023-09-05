// import 'package:flutter/material.dart';
// import 'package:movie_app/models/film.dart';

// class Previews extends StatelessWidget {
//   const Previews({super.key, required this.title, required this.contentList});

//   final String title;
//   final List<Film> contentList;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 20),
//           child: Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 165,
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (ctx, index) {
//               final content = contentList[index];
//               return InkWell(
//                 borderRadius: BorderRadius.circular(20),
//                 onTap: () {},
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 16),
//                       height: 130,
//                       width: 130,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage(content.imageUrl),
//                           fit: BoxFit.cover,
//                         ),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: content.color, width: 4),
//                       ),
//                     ),
//                     Container(
//                       height: 130,
//                       width: 130,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [
//                             Colors.black87,
//                             Colors.black45,
//                             Colors.transparent,
//                           ],
//                           stops: [0, 0.25, 1],
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                         ),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: content.color, width: 4),
//                       ),
//                     ),
//                     Positioned(
//                       left: 0,
//                       right: 0,
//                       bottom: 0,
//                       child: SizedBox(
//                         child: Image.asset(content.titleImageUrl),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//             itemCount: contentList.length,
//           ),
//         )
//       ],
//     );
//   }
// }
