import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

class PdfToImageConverter extends StatefulWidget {
  const PdfToImageConverter({Key? key}) : super(key: key);

  @override
  _PdfToImageConverterState createState() => _PdfToImageConverterState();
}

class _PdfToImageConverterState extends State<PdfToImageConverter> {
  final List<Uint8List> _pages = [];
  bool _isLoading = false;
  late String _pdfPath;

  
  Future<void> _requestPermission() async {
    const platform = MethodChannel('textify');
    try {
      await platform.invokeMethod('requestPermissions');
    } on PlatformException catch (e) {
      print('Error occurred while requesting permission: ${e.message}');
    }
  }

  Future<void> _pickPDFtoDOCX() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      print("file result: $result");

      if (result == null || result.files.single.path == null) return;

      setState(() {
        _pdfPath = result.files.single.path!;
        _convertPdfToImagesDOCX();
      });
    } on PlatformException catch (e) {
      print('Error occurred while picking the file: $e');
    }
  }

  Future<void> _convertPdfToImagesDOCX() async {
    setState(() {
      _isLoading = true;
      // _pages.clear();
    }); 

    try {
      final document = await PdfDocument.openFile(_pdfPath);
      print(_pdfPath);

      // for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(1);

      // Render PDF page to image
      final pageImage = await page.render(
        width: page.width,
        height: page.height
      );

      print("pageImage: $pageImage");

      // Save image to temporary directory
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/image.png';

      // final imageFile = await File(imagePath).writeAsBytes(pageImage!.bytes);

      await File(imagePath).writeAsBytes(pageImage!.bytes);

      await page.close();
      // }

      await document.close();
      await _requestPermission();

      await _uploadImageDOCX(File(imagePath).readAsBytesSync());
      
    } catch (e) {
      print('Error occurred while rendering PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Upload gambar ke node js (DOCX)
Future<void> _uploadImageDOCX(Uint8List imageBytes) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.1.27:3000/upload?fileType=docx'),
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

      // Read the response data as bytes
      final responseBytes = await response.stream.toBytes();

      // Save the response data as a DOCX file in the application's document directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocFile = File('${appDocDir.path}/result.docx');
      await appDocFile.writeAsBytes(responseBytes);

      // Save the response data to the Flutter device's external storage
      final downloadDir = await getExternalStorageDirectory();
      final downloadFile = File('${downloadDir!.path}/result.docx');

      print("downloaded file: $downloadFile");
      await downloadFile.writeAsBytes(responseBytes);

      // Membuka file menggunakan aplikasi pembaca dokumen bawaan
      await OpenFile.open(downloadFile.path);

      print('File downloaded successfully');

      // Now you can use the downloaded DOCX file as needed
      // For example, open the file using a third-party package or share it with other apps
    } else {
      print('Failed to upload image. Error code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while uploading image: $e');
  }
}

  Future<void> _pickPDFtoPPTX() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() {
        _pdfPath = result.files.single.path!;
        _convertPdfToImagesPPTX();
      });
    } on PlatformException catch (e) {
      print('Error occurred while picking the file: $e');
    }
  }

  Future<void> _convertPdfToImagesPPTX() async {
    setState(() {
      _isLoading = true;
      // _pages.clear();
    }); 

    try {
      final document = await PdfDocument.openFile(_pdfPath);

      // for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(1);

      // Render PDF page to image
      final pageImage = await page.render(
        width: page.width,
        height: page.height
      );

      // Save image to temporary directory
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/image.png';

      // final imageFile = await File(imagePath).writeAsBytes(pageImage!.bytes);

      await File(imagePath).writeAsBytes(pageImage!.bytes);

      await page.close();
      // }

      await document.close();
      await _requestPermission();

      await _uploadImagePPTX(File(imagePath).readAsBytesSync());
      
    } catch (e) {
      print('Error occurred while rendering PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload gambar ke node js (PPTX)
  Future<void> _uploadImagePPTX(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.27:3000/upload?fileType=pptx'),
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

        // Read the response data as bytes
        final responseBytes = await response.stream.toBytes();

        // Save the response data as a PPTX file in the application's document directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final appDocFile = File('${appDocDir.path}/result.pptx');
        await appDocFile.writeAsBytes(responseBytes);

        // Save the response data to the Flutter device's external storage
        final downloadDir = await getExternalStorageDirectory();
        final downloadFile = File('${downloadDir!.path}/result.pptx');

        print("downloaded file: $downloadFile");
        await downloadFile.writeAsBytes(responseBytes);

        // Membuka file menggunakan aplikasi pembaca dokumen bawaan
        await OpenFile.open(downloadFile.path);

        print('File downloaded successfully');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Textify',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff6C63FF),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Textify",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 10.0),
              child: Text(
                "With OCR",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.sync,
                color: Color(0xff6C63FF),
                size: 24,
              ),
              title: const Text(
                "Convert To DOCX",
                style: TextStyle(
                  color: Color(0xff6C63FF),
                  fontWeight: FontWeight.w500
                ),
              ),
              onTap: _pickPDFtoDOCX,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.sync,
                color: Color(0xff6C63FF),
                size: 24,
              ),
              title: const Text(
                "Convert To PPTX",
                style: TextStyle(
                  color: Color(0xff6C63FF),
                  fontWeight: FontWeight.w500
                ),
              ),
              onTap: _pickPDFtoPPTX,
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(top: 40.0,left: 10.0,right: 10.0,bottom: 8.0),
              child: Text(
                "Without OCR",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.sync,
                color: Color(0xff6C63FF),
                size: 24,
              ),
              title: const Text(
                "Convert To DOCX",
                style: TextStyle(
                  color: Color(0xff6C63FF),
                  fontWeight: FontWeight.w500
                ),
              ),
              onTap: (){},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.sync,
                color: Color(0xff6C63FF),
                size: 24,
              ),
              title: const Text(
                "Convert To PPTX",
                style: TextStyle(
                  color: Color(0xff6C63FF),
                  fontWeight: FontWeight.w500
                ),
              ),
              onTap: (){},
            ),
            const Divider(),
          ]
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _pages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/undraw_online_reading_np7n.png'
                        ),
                        const Text('Please select a PDF file to convert',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container()
    );
  }
}