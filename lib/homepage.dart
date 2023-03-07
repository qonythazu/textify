import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:textify/pdfs.dart';
import 'package:textify/pdfs_viewer.dart';

class PdfUploader extends StatefulWidget {
  @override
  _PdfUploaderState createState() => _PdfUploaderState();
}

class _PdfUploaderState extends State<PdfUploader> {
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
        onPressed: () async {
          final file = await PDFs.pickFiles();

          if (file == null) return;
          openPDF(context, file);
        },
        child: const Icon(Icons.upload, color: Colors.white,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          ],
        ),
      ),
    );
  }
  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFsViewer(file : file)),
  );
}