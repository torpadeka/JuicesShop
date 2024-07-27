import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final int juiceId;

  const DetailsPage({Key? key, required this.juiceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Juice Details"),
      ),
      body: Center(
        child: Text(
          'Details for Juice ID: $juiceId',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
