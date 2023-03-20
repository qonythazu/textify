import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';


class PdfToImageConverter extends StatefulWidget {
  const PdfToImageConverter({Key? key}) : super(key: key);

  @override
  _PdfToImageConverterState createState() => _PdfToImageConverterState();
}

class _PdfToImageConverterState extends State<PdfToImageConverter> {
  final List<Uint8List> _pages = [];
  bool _isLoading = false;
  late String _pdfPath;

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() {
        _pdfPath = result.files.single.path!;
        _convertPdfToImages();
      });
    } on PlatformException catch (e) {
      print('Error occurred while picking the file: $e');
    }
  }

  Future<void> _convertPdfToImages() async {
    setState(() {
      _isLoading = true;
      _pages.clear();
    });

    try {
      final document = await PdfDocument.openFile(_pdfPath);

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);

        final pageImage = await page.render(
          width: page.width,
          height: page.height,
        );

        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/temp.jpg';

        final imageFile = await File(imagePath).writeAsBytes(pageImage!.bytes);

        _pages.add(File(imagePath).readAsBytesSync());

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Textify',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _pages.isEmpty
              ? const Center(
                  child: Text('Please select a PDF file',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              : ImageListView(pages: _pages),
      floatingActionButton: _pages.isNotEmpty ? null : FloatingActionButton(
        onPressed: _pickPDF,
        tooltip: 'Pick PDF',
        child: const Icon(Icons.file_upload, color: Colors.white),
      ),
    );
  }
}

class ImageListView extends StatelessWidget {
  final List<Uint8List> pages;

  const ImageListView({Key? key, required this.pages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
      itemCount: pages.length,
      itemBuilder: (context, int index) {
        return Column(
          children: [
            Image.memory(pages[index]),
            const SizedBox(height: 10),
            ListTile(
              title: Text('Page ${index + 1}'),
              leading: Image.memory(pages[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OcrResultView(image: pages[index]),
                  ),
                );
              },
            ),
            const Divider(),
          ],
        );
      },
      ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: FloatingActionButton.extended(
      //         onPressed: (){},
      //         label: Row(
      //             children: const [
      //               Padding(
      //                 padding: EdgeInsets.only(right: 4.0),
      //                 child: Icon(Icons.swap_horiz, color: Colors.white,),
      //               ),
      //               Text("DOCX",
      //                 style: TextStyle(
      //                   color: Colors.white
      //                 ),
      //               )
      //             ],
      //           ),
      //       ),
      //     ),
      //     FloatingActionButton.extended(
      //       onPressed: (){},
      //       label: Row(
      //           children: const [
      //             Padding(
      //               padding: EdgeInsets.only(right: 4.0),
      //               child: Icon(Icons.swap_horiz, color: Colors.white,),
      //             ),
      //             Text("PPTX",
      //               style: TextStyle(
      //                 color: Colors.white
      //               ),
      //             )
      //           ],
      //         ),
      //     ),
      //   ],
      // ),
    );
  }
}

class OcrResultView extends StatefulWidget {
  final Uint8List image;

  const OcrResultView({Key? key, required this.image}) : super(key: key);

  @override
  _OcrResultViewState createState() => _OcrResultViewState();
}

class _OcrResultViewState extends State<OcrResultView> {
  String _result = '';
  bool _isLoading = true;

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
      final document = await PdfDocument.openData(widget.image);

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);

        final pageImage = await page.render(
          width: page.width,
          height: page.height,
        );

        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/temp.jpg';

        final imageFile = await File(imagePath).writeAsBytes(pageImage!.bytes);

        _performOcr(File(imagePath).readAsBytesSync());

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

  Future<void> _performOcr(List<int> imageBytes) async {
    try {
      final String text = await FlutterTesseractOcr.extractText(utf8.decode(widget.image));
      setState(() {
        _result = _result + text;
      });
    } catch (e) {
      print('Error occurred while performing OCR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/temp.jpg';
      await File(imagePath).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Result'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(child: Text(_result)),
      ),
    );
  }
}