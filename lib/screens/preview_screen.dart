import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PreviewScreen extends StatelessWidget {
  final String imagePath;

  PreviewScreen({required this.imagePath});

  Future<void> _uploadImage() async {
    final url = Uri.parse('https://tu-api.com/upload'); // Reemplaza con tu URL
    final request = http.MultipartRequest('POST', url);

    final file = File(imagePath);
    final stream = http.ByteStream(file.openRead());
    final length = await file.length();

    final multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: basename(file.path),
    );

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Imagen subida exitosamente');
    } else {
      print('Error al subir la imagen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Previsualización')),
      body: Column(
        children: [
          Image.file(File(imagePath)),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text('Subir imagen'),
          ),
        ],
      ),
    );
  }
}