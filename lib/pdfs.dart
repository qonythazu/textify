import 'dart:io';
import 'package:file_picker/file_picker.dart';

class PDFs {
  static Future<File> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf']
    );

    if (result == null) {
      throw Exception("File pick cancelled or failed");
    }
    
    final filePath = result.paths.first;
    if (filePath == null) {
      throw Exception("No file path found");
    }

    return File(filePath);
  }
}