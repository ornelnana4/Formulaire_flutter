import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Pour gérer les fichiers
import 'database_helper.dart'; // Assure-toi que le chemin est correct

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
        brightness: Brightness.light,
        fontFamily: 'Montserrat', // Ajoute une police personnalisée si nécessaire
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
  List<User> _users = [];
  int? _selectedUserId;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUsers();
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
        title: Text("Formulaire Stylé"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _pickImage, // Ouvre la caméra
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_image != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0, 5),
                            )
                          ],
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    SizedBox(height: 20.0),

                    // Champ Nom avec un joli style
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700),
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
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
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
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Bouton de soumission stylé
                    ElevatedButton(
                      onPressed: _saveUser,
                      child: Text(_selectedUserId != null ? 'Mettre à jour' : 'Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // Liste des utilisateurs
                    Text(
                      "Utilisateurs enregistrés :",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                    ),
                    SizedBox(height: 10.0),

                    _users.isEmpty
                        ? Text("Aucun utilisateur trouvé.",
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(Icons.account_circle, color: Colors.blue),
                            title: Text(_users[index].name),
                            subtitle: Text(_users[index].email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
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
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteUser(_users[index].id!);
                                    _loadUsers();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
