import 'package:flutter/material.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  final Function(BuildContext context, String name, String city)
      handleLogin; // Define el parámetro handleLogin

  LoginScreen(
      {required this.handleLogin}); // Agrega el constructor con handleLogin como parámetro requerido

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    String name = _nameController.text;
    String city = _cityController.text;

    // Llama a la función handleLogin pasando los datos a main.dart
    widget.handleLogin(context, name, city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.black54,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}