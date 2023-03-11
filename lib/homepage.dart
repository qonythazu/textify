import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

class PdfToImageConverter extends StatefulWidget {
  final String pdfPath;

  const PdfToImageConverter({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _PdfToImageConverterState createState() => _PdfToImageConverterState();
}

class _PdfToImageConverterState extends State<PdfToImageConverter> {
  List<Uint8List> _pages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _convertPdfToImages();
  }

  Future<void> _convertPdfToImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final document = await PdfDocument.openFile(widget.pdfPath);

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);

        final pageImage = await page.render(
          width: page.width,
          height: page.height,
        );

        _pages.add(pageImage!.bytes);

        await page.close();
      }

      await document.close();
    } catch (e) {
      print('Error occurred while rendering PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
    ? CircularProgressIndicator()
    : Container(
        child: ListView.builder(
          itemCount: _pages.length,
          itemBuilder: (context, index) {
            return Image.memory(_pages[index]);
          },
        ),
      );
  }
}
