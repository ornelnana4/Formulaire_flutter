import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour la caméra
import 'database_helper.dart'; // Assure-toi que le chemin est correct
import 'dart:io'; // Pour gérer les fichiers

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulaire avec SQLite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StylishForm(),
    );
  }
}

class StylishForm extends StatefulWidget {
  @override
  _StylishFormState createState() => _StylishFormState();
}

class _StylishFormState extends State<StylishForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<User> _users = []; // Liste des utilisateurs
  int? _selectedUserId; // Pour mettre à jour un utilisateur
  File? _image; // Stocker l'image capturée

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Charger les utilisateurs
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _loadUsers() async {
    _users = await DatabaseHelper().getUsers();
    setState(() {});
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedUserId = null;
  }

  Future<void> _updateUser() async {
    if (_selectedUserId != null) {
      User user = User(
        id: _selectedUserId,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      await DatabaseHelper().updateUser(user);
      _clearFields();
      _loadUsers();
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserId != null) {
        await _updateUser();
      } else {
        Map<String, dynamic> user = {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        };
        await DatabaseHelper().insertUser(user);
        _clearFields();
        _loadUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formulaire"),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: _pickImage, // Ouvre la caméra
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Affiche l'image capturée
                if (_image != null)
                  Image.file(_image!, height: 200),
                SizedBox(height: 16.0),
                // Champ Nom
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Champ Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text(_selectedUserId != null ? 'Mettre à jour' : 'Ajouter'),
                ),
                SizedBox(height: 16.0),
                // Liste des utilisateurs
                _users.isEmpty
                    ? Text("Aucun utilisateur")
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_users[index].name),
                      subtitle: Text(_users[index].email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _nameController.text = _users[index].name;
                                _emailController.text = _users[index].email;
                                _passwordController.text = _users[index].password;
                                _selectedUserId = _users[index].id;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await DatabaseHelper().deleteUser(_users[index].id!);
                              _loadUsers();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
