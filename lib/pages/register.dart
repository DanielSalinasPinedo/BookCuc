import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submitForm(BuildContext context) async {
    try {
      // Obtener el nombre de usuario y contraseña ingresados por el usuario
      String email = _usernameController.text;
      String password = _passwordController.text;

      // Crear una nueva cuenta de usuario con Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:
            email, // Suponiendo que cada usuario tiene un correo electrónico único generado a partir de su nombre de usuario
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Guardar los datos del usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'isAdmin': false, // Puedes establecer este valor como quieras
      });

      // Si el registro es exitoso, mostrar un mensaje y navegar a la página principal
      print('Registro exitoso: ${userCredential.user!.email}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registro exitoso'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
      // Aquí puedes navegar a la página principal de la aplicación
    } on FirebaseAuthException catch (e) {
      // Si hay un error al registrar, mostrar un mensaje de error
      print('Registro fallido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Registro fallido. ${e.message}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
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
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
