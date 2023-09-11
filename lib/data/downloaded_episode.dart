import 'dart:io';

import 'package:path_provider/path_provider.dart';

final List<String> episodeFileNames = [];

Future<void> getAllBackdrop() async {
  final appDir = await getApplicationDocumentsDirectory();
  final episodeDirectory = Directory('${appDir.path}/episode');

  if (!await episodeDirectory.exists()) {
    return;
  }

  final entities = episodeDirectory.listSync();

  // for (var entity in entities) {
  //   if (entity is File) {
  //     String fileName = entity.uri.pathSegments.last;
  //     backdropFileNames.add(fileName);
  //   }
  // }

  // Vì thư mục backdrop_path trong appDir chỉ toàn chứa file .mp4
  // nên không cần check "entity" là File or Directory
  episodeFileNames.addAll(
    List.generate(
      entities.length,
      (index) => entities[index].uri.pathSegments.last,
    ),
  );

  // print('episode directory = ${episodeDirectory.path}');
  print('File names = $episodeFileNames');
}
