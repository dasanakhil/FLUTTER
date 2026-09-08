import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REST API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> posts = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from REST API
  Future<void> fetchData() async {
    try {
      final response = await html.HttpRequest.getString(
        'https://jsonplaceholder.typicode.com/posts',
      );

      setState(() {
        posts = jsonDecode(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Unable to fetch data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Posts'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error.isNotEmpty
              ? Center(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${post['id']}',
                          ),
                        ),
                        title: Text(
                          post['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            post['body'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
