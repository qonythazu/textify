import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http ;

class PDFs {
  // static Future<File> loadNetwork(String, url) async {
  //   final response = await http.get(url);
  //   final bytes = response.bodyBytes;

  //   return _storeFile(url, bytes);
  // }

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

  // static Future<File> _storeFile(String url, List<int> bytes) async {
  //   final filename = basename(url);
  //   final directory = await getApplicationDocumentsDirectory();

  //   final file = File('${directory.path}/$filename');
  //   await file.writeAsBytes(bytes, flush: true);
  //   return file;
  // }
}