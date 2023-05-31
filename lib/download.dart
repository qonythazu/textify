import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadDownloadExample extends StatefulWidget {
  @override
  _FileUploadDownloadExampleState createState() =>
      _FileUploadDownloadExampleState();
}

class _FileUploadDownloadExampleState extends State<FileUploadDownloadExample> {
  final String serverUrl = 'http://192.168.1.27:3000/upload?fileType=docx'; // Ganti dengan URL server Anda

  Future<void> uploadAndDownloadFile(File file) async {
    try {
      // Upload file
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        // File berhasil diunggah, simpan respons ke direktori lokal
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(tempDir.path, 'downloaded_file');
        var fileStream = File(filePath).openWrite();
        await streamedResponse.stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();

        // Lakukan logika bisnis Anda dengan file yang diunduh
        print('File berhasil diunduh ke: $filePath');
      } else {
        // Tangani kesalahan saat mengunggah file
        print('Gagal mengunggah file: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload & Download Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Pilih file menggunakan file picker
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null) {
              File file = File(result.files.single.path!);
              await uploadAndDownloadFile(file);
            }
          },
          child: Text('Upload & Download File'),
        ),
      ),
    );
  }
}