import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  String _searchQuery = "";
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _deleteBookByTitle(String title) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: title)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('books')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Libro eliminado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Libro no encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el libro: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        if (userData['isAdmin'] == true) {
          setState(() {
            _isAdmin = true;
          });
        }
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar "$title"'),
          content:
              const Text('¿Estás seguro de que quieres eliminar este libro?'),
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
                _deleteBookByTitle(title);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar libros',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _searchQuery.isEmpty
                ? FirebaseFirestore.instance
                    .collection('books')
                    .where('availability', isEqualTo: true)
                    .snapshots()
                : FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final List<DocumentSnapshot> books = snapshot.data!.docs
                  .where((doc) => doc['title']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery))
                  .toList();

              if (books.isEmpty) {
                return const Center(child: Text('No hay libros disponibles'));
              }

              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final isAvailable = book['availability'];
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isAvailable)
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _showBorrowDialog(
                                    context,
                                    book.id,
                                    book['title'],
                                    user!.email!,
                                  );
                                },
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Este libro está prestado',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (_isAdmin && isAvailable)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    'create',
                                    arguments: {
                                      'title': book['title'],
                                      'user': user!.email!,
                                    },
                                  );
                                },
                              ),
                            if (_isAdmin && isAvailable)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, book['title']);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showBorrowDialog(
      BuildContext context, String bookId, String title, String userEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pedir prestado "$title"'),
          content: const Text(
              '¿Estás seguro de que quieres pedir prestado este libro?'),
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
                _borrowBook(bookId, userEmail);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _borrowBook(String bookId, String userEmail) {
    FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'borrowed': userEmail,
      'availability': false,
    }).then((_) {
      print('Libro pedido prestado exitosamente');
    }).catchError((error) {
      print('Error al pedir prestado el libro: $error');
    });
  }
}
