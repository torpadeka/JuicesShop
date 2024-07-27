import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    checkTokenValidity();
  }

  Future<void> checkTokenValidity() async {
    final token = await storage.read(key: 'auth_token');
    final expiresAtString = await storage.read(key: 'expires_in');
    if (token != null && expiresAtString != null) {
      final expirationDate = DateTime.parse(expiresAtString);
      if (expirationDate.isAfter(DateTime.now())) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }

  void handleLogin() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:3000/users/login'), // Change to your machine's IP if not using an emulator
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        await storage.write(key: 'auth_token', value: responseBody['token']);
        await storage.write(key: 'username', value: responseBody['username']);
        await storage.write(
            key: 'expires_in', value: responseBody['expiresIn'].toString());
        if (mounted) {
          Navigator.pushNamed(context, '/home');
        }
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');

        final errorResponse = jsonDecode(response.body);
        setState(() {
          errorMessage = errorResponse['error'] ?? 'Unknown error occurred';
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('A fatal error occured!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool isAlphanumeric(String password) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 96.0, vertical: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.asset(
                    'chillinhubwhite.png',
                    width: 200,
                    height: 200,
                  ),
                  const Text("Juices Shop", textScaleFactor: 2),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  } else if (value.length < 5) {
                    return 'Username must at least be 5 characters!';
                  } else if (value.length > 20) {
                    return 'Username can only be 20 characters at most!';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (!isAlphanumeric(value)) {
                    return 'Password must be alphanumeric';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    handleLogin();
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
