import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submitForm(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      UserCredential userCredential = await authService.signInWithEmailPassword(
          _usernameController.text, _passwordController.text);
      /*await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController
            .text, // Suponiendo que usamos el nombre de usuario como parte del correo electrónico
        password: _passwordController.text,
      );*/
      print('Inicio de sesión exitoso: ${userCredential.user!.email}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green),
      );

      //Navigator.pushNamedAndRemoveUntil(
      //  context, 'biblioteca', (route) => false);
      Navigator.pushNamed(context, 'biblioteca');
      // Aquí puedes navegar a la página principal de la aplicación
    } on FirebaseAuthException catch (e) {
      print('Inicio de sesión fallido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicio de sesión fallido.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre de usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
