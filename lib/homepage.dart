import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class PdfUploader extends StatefulWidget {
  @override
  _PdfUploaderState createState() => _PdfUploaderState();
}

class _PdfUploaderState extends State<PdfUploader> {
  File? _pdfFile;

  Future<void> _uploadPdf() async {
    if (_pdfFile != null) {
      String fileName = path.basename(_pdfFile!.path);
      String localPath = (await getApplicationDocumentsDirectory()).path;
      String filePath = '$localPath/$fileName';

      try {
        _pdfFile!.copySync(filePath);
        print('File PDF berhasil diupload ke $filePath');
      } catch (e) {
        print('Gagal mengupload file PDF: $e');
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['pdf']
      );

      if (result != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print('Gagal memilih file PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Textify',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickPdf,
        child: const Icon(Icons.upload, color: Colors.white,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16),
            if (_pdfFile != null)
              Text(_pdfFile!.path),
            SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _uploadPdf,
            //   child: Text('Upload PDF'),
            // ),
          ],
        ),
      ),
    );
  }
}