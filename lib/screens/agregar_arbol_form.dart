import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AgregarArbolForm extends StatefulWidget {
  final int idParcela;

  AgregarArbolForm({required this.idParcela});

  @override
  _AgregarArbolFormState createState() => _AgregarArbolFormState();
}

class _AgregarArbolFormState extends State<AgregarArbolForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _diametroTroncoController = TextEditingController();
  final TextEditingController _diametroCopaController = TextEditingController();
  final TextEditingController _numeroArbolController = TextEditingController();

  bool isLoading = false;
  String? authToken;

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
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final url = Uri.parse('https://hassclass.me/api/arboles'); // Reemplaza con tu URL
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'id_parcela': widget.idParcela,
            'edad': int.parse(_edadController.text),
            'altura': double.parse(_alturaController.text),
            'diametro_tronco': double.parse(_diametroTroncoController.text),
            'diametro_copa': double.parse(_diametroCopaController.text),
            'numero_arbol': int.parse(_numeroArbolController.text),
          }),
        );

        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Árbol agregado exitosamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar el árbol: ${response.body}')),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con el servidor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Fondo similar a ParcelasPage
      appBar: AppBar(
        title: Text('Agregar Árbol'),
        backgroundColor: Colors.green[700], // Color de la AppBar
        elevation: 5, // Sombra
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[800]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Contenedor con diseño similar a las tarjetas de ParcelasPage
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _edadController,
                      decoration: InputDecoration(
                        labelText: 'Edad del árbol',
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la edad del árbol';
                        }
                        if (int.tryParse(value) == null) {
                          return 'La edad debe ser un número entero';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _alturaController,
                      decoration: InputDecoration(
                        labelText: 'Altura del árbol (m)',
                        prefixIcon: Icon(Icons.height, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la altura del árbol';
                        }
                        if (double.tryParse(value) == null) {
                          return 'La altura debe ser un número';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _diametroTroncoController,
                      decoration: InputDecoration(
                        labelText: 'Diámetro del tronco (cm)',
                        prefixIcon: Icon(Icons.straighten, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el diámetro del tronco';
                        }
                        if (double.tryParse(value) == null) {
                          return 'El diámetro debe ser un número';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _diametroCopaController,
                      decoration: InputDecoration(
                        labelText: 'Diámetro de la copa (m)',
                        prefixIcon: Icon(Icons.nature, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el diámetro de la copa';
                        }
                        if (double.tryParse(value) == null) {
                          return 'El diámetro debe ser un número';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroArbolController,
                      decoration: InputDecoration(
                        labelText: 'Número de árbol',
                        prefixIcon: Icon(Icons.format_list_numbered, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el número de árbol';
                        }
                        if (int.tryParse(value) == null) {
                          return 'El número debe ser un entero';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700], // Color del botón
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Guardar Árbol',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}