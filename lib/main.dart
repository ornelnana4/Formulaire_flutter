import 'package:flutter/material.dart';
import 'database_helper.dart'; // Assure-toi que le chemin est correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulaire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
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
  List<User> _users = []; // Liste pour stocker les utilisateurs
  int? _selectedUserId; // ID de l'utilisateur sélectionné pour la mise à jour

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Charger les utilisateurs au démarrage
  }

  void _loadUsers() async {
    _users = await DatabaseHelper().getUsers();
    setState(() {});
  }

  void _populateFields(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _passwordController.text = user.password;
    _selectedUserId = user.id; // Stocker l'ID de l'utilisateur sélectionné
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedUserId = null; // Réinitialiser l'ID sélectionné
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur mis à jour avec succès !')),
      );

      _clearFields();
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formulaire"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
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
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Champ Nom
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Bouton de soumission
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedUserId != null) {
                              // Mettre à jour l'utilisateur existant
                              await _updateUser();
                            } else {
                              // Créer un nouvel utilisateur
                              Map<String, dynamic> user = {
                                'name': _nameController.text,
                                'email': _emailController.text,
                                'password': _passwordController.text,
                              };

                              // Insérer l'utilisateur dans la base de données
                              int id = await DatabaseHelper().insertUser(user);

                              // Afficher un message de succès
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Utilisateur ajouté avec succès ! ID: $id')),
                              );

                              // Réinitialiser les champs
                              _clearFields();
                              _loadUsers();
                            }
                          }
                        },
                        child: Text(_selectedUserId != null ? 'Mettre à jour' : 'Ajouter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                      SizedBox(height: 20.0),
                      // Liste des utilisateurs
                      Text(
                        "Utilisateurs:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10.0),
                      // Afficher la liste des utilisateurs
                      _users.isEmpty
                          ? Text("Aucun utilisateur trouvé.")
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_users[index].name),
                            subtitle: Text(_users[index].email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _populateFields(_users[index]); // Remplir les champs avec les données de l'utilisateur sélectionné
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteUser(_users[index].id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Utilisateur supprimé avec succès!')),
                                    );
                                    _loadUsers(); // Recharger la liste après suppression
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
          ),
        ),
      ),
    );
  }
}
