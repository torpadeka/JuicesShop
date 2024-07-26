import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthChecker(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isTokenValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data == true) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<Map<String, String?>> getToken() async {
    const storage = FlutterSecureStorage();

    String? token = await storage.read(key: 'auth_token');
    String? expiration = await storage.read(key: 'token_expiration');
    return {'token': token, 'expiration': expiration};
  }

  Future<bool> isTokenValid() async {
    final tokenData = await getToken();

    if (tokenData['token'] == null || tokenData['expiration'] == null) {
      return false;
    }

    final expirationDate = DateTime.parse(tokenData['expiration']!);
    return DateTime.now().isBefore(expirationDate);
  }
}
