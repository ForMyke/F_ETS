import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.miguelgomez.ets_android/downloads');

Future<void> savePdfToDownloads(String name, Uint8List bytes) async {
  if (Platform.isAndroid) {
    await _channel.invokeMethod<bool>('saveToDownloads', {
      'name': name,
      'bytes': bytes,
      'mimeType': 'application/pdf',
    });
    return;
  }
  await FileSaver.instance.saveFile(
    name: name,
    bytes: bytes,
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}
