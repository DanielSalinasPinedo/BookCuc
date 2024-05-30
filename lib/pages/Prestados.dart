import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Prestado extends StatefulWidget {
  const Prestado({super.key});

  @override
  _PrestadoState createState() => _PrestadoState();
}

class _PrestadoState extends State<Prestado> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('borrowed', isEqualTo: user?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<DocumentSnapshot> books = snapshot.data!.docs;

        if (books.isEmpty) {
          return const Center(
            child: Text(
              'No tienes libros prestados',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              child: Column(
                children: [
                  Image.network(
                    book['imageUrl'],
                    height: 320,
                  ),
                  Text(
                    book['title'],
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Año: ${book['year']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () {
                      _showReturnDialog(
                        context,
                        book.id,
                        book['title'],
                        user!.email!,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReturnDialog(
      BuildContext context, String bookId, String title, String userEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Devolver "$title"'),
          content:
              const Text('¿Estás seguro de que quieres devolver este libro?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                _returnBook(bookId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _returnBook(String bookId) {
    FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'borrowed': '',
      'availability': true,
    }).then((_) {
      print('Libro devuelto exitosamente');
    }).catchError((error) {
      print('Error al devolver el libro: $error');
    });
  }
}
