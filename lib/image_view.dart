import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final Uint8List imageData;

  const ImagePreview({Key? key, required this.imageData}) : super(key: key);

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
      body: Image.memory(
        imageData,
        fit: BoxFit.contain,
      ),
    );
  }
}
