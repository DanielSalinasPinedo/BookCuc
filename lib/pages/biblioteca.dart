import 'package:bookcuc/pages/404.dart';
import 'package:bookcuc/pages/Prestados.dart';
import 'package:bookcuc/pages/auth_service.dart';
import 'package:bookcuc/pages/books.dart';
import 'package:bookcuc/pages/c_books.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class Biblioteca extends StatefulWidget {
  const Biblioteca({super.key});

  @override
  State<Biblioteca> createState() => _BibliotecaState();
}

class _BibliotecaState extends State<Biblioteca> {
  int _selectDrawerItem = 0;
  bool _isAdmin = false;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return Books();

      case 1:
        return const Prestado();

      case 2:
        return const CreateBook();

      default:
        return const Page404();
    }
  }

  _onSelectItem(int pos) {
    setState(() {
      _selectDrawerItem = pos;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        Navigator.pushNamed(context, "/");
        print("No autorizado");
      }
    });

    return Scaffold(
      appBar: AppBar(
          title: const Text('Bienvenido a BookCuc'),
          backgroundColor: Colors.blue),
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
          stream: user != null
              ? firestore
                  .collection('users')
                  .where('email', isEqualTo: user.email)
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.docs.firstWhereOrNull(
                (doc) =>
                    (doc.data() as Map<String, dynamic>?)
                        ?.containsKey('isAdmin') ??
                    false,
              );
              _isAdmin =
                  (userData?.data() as Map<String, dynamic>?)?['isAdmin'] ??
                      false;

              print(_isAdmin);
            }

            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  currentAccountPicture: Image.network(
                      "https://www.cuc.edu.co/wp-content/uploads/2024/03/logo_cuc_vertical.png"),
                  accountName: Text(user != null
                      ? user.email!.toLowerCase().split("@")[0]
                      : "No hay usuario autenticado"),
                  accountEmail: Text(user != null
                      ? user.email!.toLowerCase()
                      : "No hay usuario autenticado"),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Inicio"),
                  onTap: () {
                    _onSelectItem(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text("Prestados"),
                  onTap: () {
                    _onSelectItem(1);
                  },
                ),
                if (_isAdmin)
                  ListTile(
                    leading: const Icon(Icons.add_circle),
                    title: const Text("Crear Libro"),
                    onTap: () {
                      _onSelectItem(2);
                    },
                  ),
                const Divider(
                  height: 6,
                  color: Colors.black,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Cerrar Sesion"),
                  onTap: () {
                    authService.signOut();
                    Navigator.pushNamed(context, '/');
                    print(user!.email!.toLowerCase());
                  },
                )
              ],
            );
          },
        ),
      ),
      body: _getDrawerItemWidget(_selectDrawerItem),
    );
  }
}
