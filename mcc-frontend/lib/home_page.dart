import 'dart:convert';

import 'package:JuicesShop/details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  int currentPageIndex = 0; // 0 for home, 1 for items (juices) page
  List<Map<String, dynamic>> juices = [];
  String username = "User";

  void handleLogout() {
    storage.delete(key: 'auth_token');
    storage.delete(key: 'expires_in');
    storage.delete(key: 'username');
    storage.delete(key: 'user_id');
    Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    checkTokenValidity();
  }

  Future<void> checkTokenValidity() async {
    final authToken = await storage.read(key: 'auth_token');
    final expirationString = await storage.read(key: 'expires_in');

    if (authToken != null && expirationString != null) {
      final expiration = DateTime.parse(expirationString);
      if (DateTime.now().isAfter(expiration)) {
        if (mounted) {
          storage.delete(key: 'auth_token');
          storage.delete(key: 'expires_in');
          storage.delete(key: 'username');
          storage.delete(key: 'user_id');
          Navigator.pushNamed(context, '/login');
        }
      } else {
        fetchJuices();
        fetchUsername();
      }
    } else {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
    }
  }

  Future<void> fetchUsername() async {
    final fetchedUsername = await storage.read(key: 'username');
    if (fetchedUsername != null) {
      setState(() {
        username = fetchedUsername;
      });
    }
  }

  Future<void> fetchJuices() async {
    try {
      final authToken = await storage.read(key: 'auth_token');
      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/juices/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        print('Response Body: $responseBody'); // Debug statement

        setState(() {
          juices = List<Map<String, dynamic>>.from(responseBody);
          print('Juices: $juices');
        });
      } else {
        print('Failed to load juices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching juices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          title: const Text("Juices Shop"),
          actions: [
            ElevatedButton(
                onPressed: () {
                  handleLogout();
                },
                child: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                )),
          ],
        ),
        body: Column(
          children: [
            NavigationBar(
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.blender),
                  icon: Icon(Icons.blender_outlined),
                  label: 'Juices',
                ),
              ],
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: IndexedStack(
                  index: currentPageIndex,
                  children: [
                    Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(height: 300.0),
                          items: [1, 2, 3, 4].map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.black12,
                                    padding: const EdgeInsets.all(16.0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    // decoration: const BoxDecoration(
                                    //   color: Colors.black
                                    // ),
                                    child: Image.asset('carousel-$i.jpg'));
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 64),
                        Text(
                          "Welcome $username",
                          textScaleFactor: 2,
                        ),
                        const SizedBox(height: 64),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'chillinhubwhite.png',
                              width: 100,
                            ),
                            const SizedBox(width: 32),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: const Text(
                                "Our Juice Shop sells very high quality and hand-made juice beverages made for those who are looking for a very refreshing drink at an affordable price!",
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    juices.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: juices.length,
                            itemBuilder: (context, index) {
                              final juice = juices[index];
                              final imagePath = juice['image'] ?? '';
                              final imageUrl =
                                  'http://127.0.0.1:3000/images/${imagePath.replaceAll('public\\images\\', '')}';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(juiceId: juice['id']),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    leading: Image.network(imageUrl),
                                    title: Text(juice['name']),
                                    subtitle: Text('${juice['price']}'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
