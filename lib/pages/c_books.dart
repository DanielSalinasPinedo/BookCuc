import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBook extends StatefulWidget {
  const CreateBook({Key? key}) : super(key: key);

  @override
  _CreateBookState createState() => _CreateBookState();
}

class _CreateBookState extends State<CreateBook> {
  String? bookTitle = "";
  String? user;

  bool _isAdmin = false;
  bool _isLoading = true;

  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      bookTitle = args['title'] as String?;
      user = args['user'] as String?;

      _fetchBookData(bookTitle!);
      _fetchUserData(user);
    }
  }

  Future<void> _fetchBookData(String title) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: title)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final bookData = snapshot.docs.first.data();
      setState(() {
        _authorController.text = bookData['author'];
        _titleController.text = bookData['title'];
        _yearController.text = bookData['year'];
        _imageUrlController.text = bookData['imageUrl'];
        _availability = bookData['availability'];
      });
    }
  }

  Future<void> _fetchUserData(String? userEmail) async {
    if (userEmail != null && userEmail.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        setState(() {
          _isAdmin = userData['isAdmin'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _availability = true;
  final String _borrowed = '';

  bool _validarTexto() {
    return (_authorController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _imageUrlController.text.isEmpty);
  }

  void _createBook() async {
    if (_validarTexto()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor llena todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (bookTitle!.isEmpty) {
        // Crear un nuevo libro
        await FirebaseFirestore.instance.collection('books').add({
          'author': _authorController.text,
          'title': _titleController.text,
          'year': _yearController.text,
          'imageUrl': _imageUrlController.text,
          'availability': _availability,
          'borrowed': _borrowed,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Libro creado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Editar un libro existente
        final snapshot = await FirebaseFirestore.instance
            .collection('books')
            .where('title', isEqualTo: bookTitle)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final bookId = snapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('books')
              .doc(bookId)
              .update({
            'author': _authorController.text,
            'title': _titleController.text,
            'year': _yearController.text,
            'imageUrl': _imageUrlController.text,
            'availability': _availability,
            'borrowed': _borrowed,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Libro editado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el libro: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bookTitle!.isNotEmpty
          ? AppBar(
              title: const Text('Editar Libro'),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                bookTitle!.isEmpty ? "Crear Libro" : "",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Autor'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL de la Imagen'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Disponibilidad: '),
                Switch(
                  value: _availability,
                  onChanged: (value) {
                    setState(() {
                      _availability = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => {
                _createBook(),
                if (!_validarTexto())
                  {Navigator.pushNamed(context, 'biblioteca')}
              },
              child: Text(bookTitle!.isEmpty ? "Crear Libro" : "Editar Libro"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authorController.dispose();
    _titleController.dispose();
    _yearController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
