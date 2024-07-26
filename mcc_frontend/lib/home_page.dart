import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Juices Shop"),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(100),
          padding: const EdgeInsets.all(10),
          color: Colors.deepPurple,
          height: 100,
          width: 100,
          child: const Text("View our Juices!"),
        ),
      ),
    );
  }
}
