import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'agregar_arbol_form.dart'; // Importa la nueva vista

class ParcelasPage extends StatefulWidget {
  @override
  _ParcelasPageState createState() => _ParcelasPageState();
}

class _ParcelasPageState extends State<ParcelasPage> {
  List<dynamic> parcelas = [];
  String? authToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('token');
    });

    if (authToken != null) {
      Future.delayed(Duration(milliseconds: 500), fetchParcelas);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchParcelas() async {
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://hassclass.me/api/parcelas'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          parcelas = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: firstCamera),
      ),
    );

    if (image != null) {
      // Aquí puedes manejar la imagen capturada (por ejemplo, enviarla a la API)
      print('Imagen capturada: ${image.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen capturada: ${image.path}')),
      );

      // Enviar la imagen a la API
      await _uploadImage(image);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('https://hassclass.me/api/upload'); // Reemplaza con tu URL
      final request = http.MultipartRequest('POST', url);

      // Adjunta el archivo de la imagen
      final file = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(file);

      // Agrega el token de autenticación en los headers
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Accept'] = 'application/json';

      // Envía la solicitud
      final response = await request.send();

      // Verifica el código de respuesta
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen subida exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green[700],
          elevation: 5,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nature_people, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Parcelas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white), // Botón de cámara
              onPressed: _openCamera, // Método para abrir la cámara
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchParcelas,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : parcelas.isEmpty
          ? Center(
        child: Text(
          'No hay parcelas disponibles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: parcelas.length,
          itemBuilder: (context, index) {
            final parcela = parcelas[index];

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Divider(color: Colors.green[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '📍 Ubicación',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              parcela['ubicacion'] ?? 'No disponible',
                              style: TextStyle(color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '🌿 Hectáreas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              parcela['numero_hectareas']?.toString() ?? 'No disponible',
                              style: TextStyle(color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '🌳 Árboles',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              parcela['numero_arboles']?.toString() ?? 'No disponible',
                              style: TextStyle(color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar a la vista de agregar árbol con un ID estático (1)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgregarArbolForm(idParcela: 1), // ID estático
                          ),
                        );
                      },
                      child: Text('Agregar Árbol'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tomar foto')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      Navigator.pop(context, image); // Retorna la imagen capturada
    } catch (e) {
      print("Error al tomar la foto: $e");
    }
  }
}