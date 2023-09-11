import 'dart:io';

import 'package:path_provider/path_provider.dart';

late final List<String> backdropFileNames;

Future<void> getAllBackdrop() async {
  final appDir = await getApplicationDocumentsDirectory();
  final backdropDirectory = Directory('${appDir.path}/backdrop_path');
  final entities = backdropDirectory.listSync();

  // for (var entity in entities) {
  //   if (entity is File) {
  //     String fileName = entity.uri.pathSegments.last;
  //     backdropFileNames.add(fileName);
  //   }
  // }

  // Vì thư mục backdrop_path trong appDir chỉ toàn chứa file image
  // nên không cần check "entity" là File or Directory
  backdropFileNames = List.generate(
    entities.length,
    (index) => entities[index].uri.pathSegments.last,
  );

  print('File names = $backdropFileNames');
}
