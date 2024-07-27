import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'route_aware_widget.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      home: const AuthChecker(),
      routes: {
        '/home': (context) => const RouteAwareWidget(child: HomePage()),
        '/login': (context) => const RouteAwareWidget(child: LoginPage()),
        '/register': (context) => const RouteAwareWidget(child: RegisterPage()),
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
    String? expiration = await storage.read(key: 'expires_in');
    return {'token': token, 'expires_in': expiration};
  }

  Future<bool> isTokenValid() async {
    final tokenData = await getToken();

    if (tokenData['token'] == null || tokenData['expires_in'] == null) {
      return false;
    }

    final expirationDate = DateTime.parse(tokenData['expires_in']!);
    return DateTime.now().isBefore(expirationDate);
  }
}
