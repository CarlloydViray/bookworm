import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class myFavesScreenView extends StatefulWidget {
  const myFavesScreenView(
      {super.key,
      required this.isbn,
      required this.title,
      this.author,
      this.publish_year,
      this.bookKey,
      this.position});

  final isbn;
  final title;
  final author;
  final publish_year;
  final bookKey;
  final position;

  @override
  State<myFavesScreenView> createState() => _myFavesScreenViewState();
}

class _myFavesScreenViewState extends State<myFavesScreenView> {
  var desc = 'No description was made for this book.';
  Future<String> fetchDescription(String key) async {
    final response =
        await http.get(Uri.parse('https://openlibrary.org$key.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        final description = data['description'];
        return description;
      } else {
        throw Exception('No books found');
      }
    } else {
      throw Exception('Failed to fetch book');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDescription(widget.bookKey).then((value) {
      setState(() {
        desc = value;
      });
    }).catchError((error) {
      setState(() {
        desc = 'No description was made for this book.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Favorite Book # ${widget.position}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 5.0,
                    ),
                  ),
                  child: Image.network(
                      'https://covers.openlibrary.org/b/isbn/${widget.isbn}-M.jpg'),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "by: " + widget.author,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  "Published on: ${widget.publish_year}",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(
                  height: 12,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Decsription',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(desc),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
