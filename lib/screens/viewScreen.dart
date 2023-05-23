import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class viewScreen extends StatefulWidget {
  const viewScreen(
      {super.key,
      required this.isbn,
      required this.title,
      this.author,
      this.publish_year,
      this.bookKey});

  final isbn;
  final title;
  final author;
  final publish_year;
  final bookKey;

  @override
  State<viewScreen> createState() => _viewScreenState();
}

class _viewScreenState extends State<viewScreen> {
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

  void addItem() async {
    final userID = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> todoMap = {
      'title': widget.title,
      'isbn': widget.isbn,
      'author': widget.author,
      'publish_year': widget.publish_year,
      'bookKey': widget.bookKey,
    };
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(userID);
    await documentReference.update({
      'faves': FieldValue.arrayUnion([todoMap]),
    });

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: 'Item added successfully',
        contentType: ContentType.success,
      ),
      duration: const Duration(milliseconds: 2500),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
        title: const Text('Book Details'),
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
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(
                                    0xff675D50)), // Change the background color
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white), // Change the text color
                          ),
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          label: const Text('Add to my favorites'),
                          onPressed: () {
                            QuickAlert.show(
                              backgroundColor: const Color(0xFFF4EEE0),
                              context: context,
                              type: QuickAlertType.confirm,
                              onConfirmBtnTap: () {
                                print(widget.title);
                                print(widget.author);
                                print(widget.isbn);
                                print(desc);
                                Navigator.pop(context);
                                addItem();
                              },
                            );
                          },
                        )
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
