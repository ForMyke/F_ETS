import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

Future<void> savePdfToDownloads(String name, Uint8List bytes) async {
  await FileSaver.instance.saveFile(
    name: name,
    bytes: bytes,
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}
