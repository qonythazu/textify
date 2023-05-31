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
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> downloadFile(String fileType) async {
  var url;
  var fileName;

  // Determine URL and fileType based on certain conditions
  if (fileType == 'docx') {
    url = 'http://192.168.1.27:3000/upload?fileType=docx';
    fileName = 'result.docx'; // Expected file name on the server
  } else if (fileType == 'pptx') {
    url = 'http://192.168.1.27:3000/upload?fileType=pptx';
    fileName = 'result.pptx'; // Expected file name on the server
  } else {
    print('Failed to get conversion result');
    return;
  }

  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Get the converted file from the response
    var bytes = response.bodyBytes;

    // Save the file to the device's temporary storage
    var tempDir = await getTemporaryDirectory();
    var filePath = '${tempDir.path}/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    // Show a message indicating the file has been successfully downloaded
    print('File downloaded successfully: ${file.path}');
  } else {
    // Handle errors if necessary
    print('An error occurred: ${response.statusCode}');
    print(response.reasonPhrase);
  }
}


  Future<String> getCustomTemporaryDirectory() async {
    // Dapatkan direktori temporary default
    var tempDir = await getTemporaryDirectory();

    // Tentukan lokasi folder khusus
    var customTempDir = '${tempDir.path}/custom_temp_folder';

    // Buat direktori jika belum ada
    await Directory(customTempDir).create(recursive: true);

    return customTempDir;
  }
}