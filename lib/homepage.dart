import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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

        // Calculate aspect ratio of PDF page
        final aspectRatio = page.width / page.height;

        // Calculate desired image size (e.g. 800 x 600)
        final desiredWidth = 800;
        final desiredHeight = (desiredWidth / aspectRatio).round();

        // Render PDF page to image
        final pageImage = await page.render(
          width: desiredWidth.toDouble(),
          height: desiredHeight.toDouble(),
        );

        // Crop image to desired aspect ratio
        final cropRect = Rect.fromLTWH(0, 0, desiredWidth.toDouble(), desiredHeight.toDouble());
        final croppedImage = await cropImage(pageImage!.bytes, cropRect, desiredWidth.toDouble(), desiredHeight.toDouble());

        // Save image to temporary directory
        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/image.png';

        final imageFile = await File(imagePath).writeAsBytes(croppedImage);

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

  Future<Uint8List> cropImage(Uint8List imageBytes, Rect cropRect, double width, double height) async {
    final completer = Completer<Uint8List>();
    final decoder = await ui.instantiateImageCodec(imageBytes);
    final frame = await decoder.getNextFrame();
    final croppedImage = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    final croppedBytes = await croppedImage!.buffer.asUint8List();
    final croppedImageWidget = Image.memory(croppedBytes);
    final cropKey = GlobalKey();
    final cropWidget = ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.contain,
          child: croppedImageWidget,
        ),
      ),
    );
    final boundary = cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    completer.complete(byteData!.buffer.asUint8List());
    return completer.future;
  }


  // Upload gambar ke node js
  Future<void> _uploadImage(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.20/upload'),
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