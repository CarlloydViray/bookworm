import 'dart:convert';
import 'package:bookworm_viraycarlloyd/screens/viewScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class mainScreen extends StatefulWidget {
  const mainScreen({super.key});

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  final FocusNode _focusNode = FocusNode();
  TextEditingController search = TextEditingController();
  List<dynamic> books = [];
  List<dynamic> full = [];
  bool isLoading = false;

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
            centerTitle: true,
            title: const Text('Bookworm'),
            leading: IconButton(
                onPressed: () {
                  ZoomDrawer.of(context)!.toggle();
                },
                icon: const Icon(Icons.menu)),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                    onPressed: () {
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.info,
                          title: 'About me',
                          text:
                              'I am Carlloyd Viray, student of PSU UC. Currently a third year student under the BSIT Program',
                          confirmBtnText: 'ediwow');
                    },
                    icon: const Icon(Icons.book_outlined)),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Card(
                      child: TextField(
                        onSubmitted: (value) {
                          _focusNode.unfocus();
                          setState(() {
                            books = [];
                          });

                          searchBooks(search.text).then((results) {
                            setState(() {
                              books = results;
                            });
                          });
                        },
                        textCapitalization: TextCapitalization.words,
                        focusNode: _focusNode,
                        controller: search,
                        decoration: const InputDecoration(
                          labelText: 'Book',
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        color: Colors.black,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.red,
                        onPressed: () {
                          _focusNode.unfocus();
                          setState(() {
                            books = [];
                            isLoading = true;
                          });

                          searchBooks(search.text).then((results) {
                            setState(() {
                              books = results;
                              isLoading = false;
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 5,
                  color: Color(0xffC58940),
                  endIndent: 5,
                  indent: 5,
                ),
                const SizedBox(
                  height: 5,
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
                      final publishYear = book['first_publish_year'];
                      final bookKey = book['key'];

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
                                leading: const CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            final response = snapshot.data!;
                            if (response.statusCode == 200) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      CupertinoPageRoute(builder: (context) {
                                    return viewScreen(
                                      isbn: isbn,
                                      title: title,
                                      author: author,
                                      publish_year: publishYear,
                                      bookKey: bookKey,
                                    );
                                  }));
                                },
                                child: Card(
                                  elevation: 10,
                                  shadowColor: const Color(0xffC58940),
                                  child: ListTile(
                                      title: Text(title),
                                      subtitle: Text(author),
                                      leading: Image.network(
                                        'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg',
                                        height: 50,
                                        width: 50,
                                      )),
                                ),
                              );
                            }
                          }

                          return Card(
                            elevation: 50,
                            child: ListTile(
                              title: Text(title),
                              subtitle: Text(author),
                              leading: const Icon(
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
