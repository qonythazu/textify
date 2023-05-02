import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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

        // Render PDF page to image
        final pageImage = await page.render(
          width: page.width,
          height: page.height
        );

        // Save image to temporary directory
        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/image.png';

        final imageFile = await File(imagePath).writeAsBytes(pageImage!.bytes);

        _pages.add(File(imagePath).readAsBytesSync());

        await page.close();
      }

      await document.close();

      _uploadImage(_pages[0]);
    } catch (e) {
      print('Error occurred while rendering PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Upload gambar ke node js
  Future<void> _uploadImage(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.20:3000/upload'),
    );
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'image.png',
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while uploading image: $e');
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
      floatingActionButton: _pages.isNotEmpty ? null : FloatingActionButton(
        onPressed: _pickPDF,
        tooltip: 'Pick PDF',
        child: const Icon(Icons.file_upload, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
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
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _pages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Image.memory(
                      _pages[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
    );
  }
}