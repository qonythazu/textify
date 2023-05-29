import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ConvertResult extends StatefulWidget {
  final String fileType;
  const ConvertResult({Key? key, required this.fileType}) : super(key: key);

  @override
  _ConvertResultState createState() => _ConvertResultState();
}

class _ConvertResultState extends State<ConvertResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert Result'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            downloadFile(widget.fileType);
          },
          child: const Text(
            'Download File',
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }

  void downloadFile(String fileType) async {
    var url;

    // Tentukan URL dan fileType berdasarkan kondisi tertentu
    if (fileType == 'docx') {
      url = 'http://192.168.1.9:3000/upload?fileType=docx';
    } else if (fileType == 'pptx') {
      url = 'http://192.168.1.9:3000/upload?fileType=pptx';
    } else {
      print('Gagal Mendapatkan Hasil Konversi');
      return;
    }

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Mengambil file hasil konversi dari respons
      var bytes = response.bodyBytes;

      // Menentukan nama file berdasarkan jenis file yang diminta
      var fileName = 'result.$fileType';

      // Menyimpan file ke penyimpanan lokal di perangkat Flutter
      var dir = await getTemporaryDirectory();
      File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Tampilkan pesan bahwa file berhasil diunduh
      print('File berhasil diunduh: ${file.path}');
    } else {
      // Handle kesalahan jika diperlukan
      print('Terjadi kesalahan: ${response.statusCode}');
      print(response.body);
    }
  }
}