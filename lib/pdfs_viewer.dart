import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';


class PDFsViewer extends StatefulWidget {
  final File file;
  const PDFsViewer({super.key, required this.file});

  @override
  State<PDFsViewer> createState() => _PDFsViewerState();
}

class _PDFsViewerState extends State<PDFsViewer> {
  @override
  Widget build(BuildContext context) {
    final name = basename(widget.file.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name, 
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        iconTheme:const IconThemeData(color: Colors.white)
      ),
      body: PDFView(
        filePath: widget.file.path,
      ),
    );
  }
}