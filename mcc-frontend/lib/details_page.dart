import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DetailsPage extends StatefulWidget {
  final int juiceId;

  const DetailsPage({Key? key, required this.juiceId}) : super(key: key);

  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _reviewController = TextEditingController();
  Map<String, dynamic>? juiceDetails;
  List<Map<String, dynamic>> reviews = [];
  bool isLoadingJuice = true;
  bool isLoadingReviews = true;
  bool isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    fetchJuiceDetails();
    fetchReviews();
  }

  Future<void> fetchJuiceDetails() async {
    final authToken = await storage.read(key: 'auth_token');
    if (authToken == null) {
      print('No authentication token found');
      return;
    }

    final url = 'http://127.0.0.1:3000/juices/${widget.juiceId}';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken,
        'Cache-Control': 'no-cache',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        if (responseBody is List) {
          juiceDetails = responseBody.isNotEmpty ? responseBody[0] : null;
        } else if (responseBody is Map<String, dynamic>) {
          juiceDetails = responseBody;
        }
        isLoadingJuice = false;
      });
    } else {
      setState(() {
        isLoadingJuice = false;
      });
      print('Failed to load juice details: ${response.statusCode}');
    }
  }

  Future<void> fetchReviews() async {
    final authToken = await storage.read(key: 'auth_token');
    if (authToken == null) {
      print('No authentication token found');
      return;
    }

    final url = 'http://127.0.0.1:3000/reviews/juice/${widget.juiceId}';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken,
        'Cache-Control': 'no-cache',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      List<Map<String, dynamic>> reviewsWithUsernames = [];

      for (var review in responseBody) {
        final userId = review['userId'];
        final username = await fetchUsername(userId);
        reviewsWithUsernames.add({
          'username': username,
          ...review,
        });
      }

      setState(() {
        reviews = reviewsWithUsernames;
        isLoadingReviews = false;
      });
    } else {
      setState(() {
        isLoadingReviews = false;
      });
      print('Failed to load reviews: ${response.statusCode}');
    }
  }

  Future<String?> fetchUsername(int userId) async {
    final url = 'http://127.0.0.1:3000/users/info/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['username'];
    } else {
      print('Failed to load username: ${response.statusCode}');
      return null;
    }
  }

  Future<void> submitReview() async {
    setState(() {
      isSubmittingReview = true;
    });

    final authToken = await storage.read(key: 'auth_token');
    final userId = await storage.read(key: 'user_id');
    if (authToken == null || userId == null) {
      print('No authentication token or user ID found');
      setState(() {
        isSubmittingReview = false;
      });
      return;
    }

    const url = 'http://127.0.0.1:3000/reviews/create';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken,
      },
      body: jsonEncode({
        'userId': userId,
        'juiceId': widget.juiceId,
        'review': _reviewController.text,
      }),
    );

    if (response.statusCode == 201) {
      // Review created successfully
      _reviewController.clear();
      fetchReviews(); // Refresh the reviews
    } else {
      print('Failed to submit review: ${response.statusCode}');
    }

    setState(() {
      isSubmittingReview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Juice Details'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.blender), text: 'Details'),
              Tab(icon: Icon(Icons.comment), text: 'Comments'),
            ],
          ),
        ),
        body: isLoadingJuice || isLoadingReviews
            ? const Center(child: CircularProgressIndicator())
            : juiceDetails == null
                ? const Center(child: Text('Failed to load juice details'))
                : TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              'http://127.0.0.1:3000/images/${juiceDetails!['image'].replaceAll('public\\images\\', '')}',
                              height: 200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              juiceDetails!['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Price: ${juiceDetails!['price']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "DESCRIPTION:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              juiceDetails!['description'],
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "WRITE A REVIEW:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _reviewController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your review',
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  isSubmittingReview ? null : submitReview,
                              child: isSubmittingReview
                                  ? const CircularProgressIndicator()
                                  : const Text('Submit Review'),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(review['username'] ?? 'Unknown'),
                              subtitle: Text(review['review'] ?? ''),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}
