import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

class mainScreen extends StatefulWidget {
  const mainScreen({super.key});

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  TextEditingController search = TextEditingController();
  List<dynamic> books = [];

  Future<List<dynamic>> searchBooks(String query) async {
    final response = await http
        .get(Uri.parse('https://openlibrary.org/search.json?q=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['docs'] != null) {
        return data['docs'];
      } else {
        throw Exception('No books found');
      }
    } else {
      throw Exception('Failed to search books');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('MAIN'),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    FirebaseAuth.instance.signOut();
                  },
                  child: Text('Signout'))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      controller: search,
                      decoration: InputDecoration(label: Text('Book')),
                    ),
                    Positioned(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            books = []; // Clear the book list when searching
                          });

                          searchBooks(search.text).then((results) {
                            setState(() {
                              books = results;
                            });
                          });
                        },
                        child: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isbn = book['isbn']?.isEmpty ?? true
                          ? 'N/A'
                          : book['isbn'][0];
                      final author =
                          book['author_name']?.join(', ') ?? 'Unknown Author';
                      final title = book['title'];

                      return FutureBuilder<http.Response>(
                        future: http.get(Uri.parse(
                            'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg')),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Card(
                              elevation: 50,
                              child: ListTile(
                                title: Text(title),
                                subtitle: Text(author),
                                leading: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            final response = snapshot.data!;
                            if (response.statusCode == 200) {
                              return Card(
                                elevation: 50,
                                child: ListTile(
                                    title: Text(title),
                                    subtitle: Text(author),
                                    leading: Image.network(
                                      'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg',
                                      height: 50,
                                      width: 50,
                                    )),
                              );
                            }
                          }

                          return Card(
                            elevation: 50,
                            child: ListTile(
                              title: Text(title),
                              subtitle: Text(author),
                              leading: Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
