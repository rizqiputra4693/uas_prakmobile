import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk bekerja dengan JSON
import 'package:http/http.dart' as http; // Untuk koneksi HTTP
import 'package:flutter_uas/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk SharedPreferences
import 'package:flutter_uas/editprofilescreen.dart'; // Import screen untuk Edit Profile

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggedIn = false;
  String username = '';
  String email = '';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<List<dynamic>> _loadUserData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData; // Mengembalikan data user
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void login(String username, String password) async {
    try {
      final List<dynamic> users = await _loadUserData();
      bool foundUser = false;

      for (var user in users) {
        if (user['username'] == username && user['password'] == password) {
          setState(() {
            isLoggedIn = true;
            this.username = user['username'];
            email = user['email'];
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', user['username']);
          await prefs.setString('email', user['email']);
          foundUser = true;
          break;
        }
      }

      if (!foundUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading user data.')),
      );
    }
  }

  void logout() async {
    setState(() {
      isLoggedIn = false;
      username = '';
      email = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedEmail = prefs.getString('email');

    if (savedUsername != null && savedEmail != null) {
      setState(() {
        isLoggedIn = true;
        username = savedUsername;
        email = savedEmail;
      });
    }
  }

  void _updateProfile(String newUsername, String newEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    await prefs.setString('email', newEmail);

    setState(() {
      username = newUsername;
      email = newEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoggedIn ? _buildProfileView() : _buildLoginView(),
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            login(usernameController.text, passwordController.text);
          },
          child: const Text('Login'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text('Daftar Akun'),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundImage: const AssetImage(
              'assets/images/qiqi.png',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Tombol Edit Profile
        Center(
          child: ElevatedButton(
            onPressed: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    username: username,
                    email: email,
                  ),
                ),
              );
              if (updated == true) {
                _checkLoginStatus(); // Reload data user setelah edit
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}
