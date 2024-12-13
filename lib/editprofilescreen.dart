import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String email;

  const EditProfileScreen(
      {Key? key, required this.username, required this.email})
      : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
  }

  Future<void> _updateUserData(String newUsername, String newEmail) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        final userIndex =
            users.indexWhere((user) => user['username'] == widget.username);

        if (userIndex != -1) {
          users[userIndex]['username'] = newUsername;
          users[userIndex]['email'] = newEmail;

          // Kirim data ke server menggunakan PUT
          final updateResponse = await http.put(
            Uri.parse('http://localhost:3000/users/${users[userIndex]['id']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(users[userIndex]),
          );

          if (updateResponse.statusCode == 200) {
            Navigator.pop(context, true); // Kembalikan ke halaman profil
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
          } else {
            throw Exception('Failed to update user');
          }
        }
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _updateUserData(usernameController.text, emailController.text);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
