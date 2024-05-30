import 'package:bookcuc/pages/widgets/gradient_back.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        Navigator.pushNamed(context, "biblioteca");
        print("Autorizado");
      }
    });

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GradientBack("", double.infinity),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Bienvenido \n Biblioteca CUC",
                style: TextStyle(
                    fontSize: 37.0,
                    fontFamily: "Lato",
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green), // Color de fondo del botón
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Color del texto del botón
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Bordes redondeados
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0), // Espaciado interno del botón
                  child: Text('Iniciar Sesion'),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'register');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green), // Color de fondo del botón
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Color del texto del botón
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Bordes redondeados
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0), // Espaciado interno del botón
                  child: Text('Registrarse'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
