import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bookworm_viraycarlloyd/screens/myFavesViewScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:quickalert/quickalert.dart';

class faveScreen extends StatefulWidget {
  const faveScreen({super.key});

  @override
  State<faveScreen> createState() => _faveScreenState();
}

class _faveScreenState extends State<faveScreen> {
  void _deleteItem(int index) async {
    await deleteData(index);
    Navigator.pop(context);
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: 'Item deleted successfully',
        contentType: ContentType.success,
      ),
      duration: const Duration(milliseconds: 2500),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: StreamBuilder<List<dynamic>>(
          stream: getData(),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<dynamic> data = snapshot.data!;

            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  int position = index + 1;
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Slidable(
                      endActionPane: ActionPane(
                          extentRatio: 0.8,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.confirm,
                                    confirmBtnText: 'Delete',
                                    onConfirmBtnTap: () {
                                      _deleteItem(index);
                                    });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                          ]),
                      child: SizedBox(
                        height: 85,
                        child: Animate(
                          effects: const [
                            FadeEffect(),
                            SlideEffect(curve: Curves.easeIn),
                          ],
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return myFavesScreenView(
                                  isbn: data[index]['isbn'],
                                  title: data[index]['title'],
                                  author: data[index]['author'],
                                  publish_year: data[index]['publish_year'],
                                  bookKey: data[index]['bookKey'],
                                  position: position,
                                );
                              }));
                            },
                            child: Card(
                              elevation: 30,
                              child: ListTile(
                                title: Text(data[index]['title'].toString()),
                                subtitle: Text("by: ${data[index]['author']}"),
                                trailing: const Icon(
                                  Icons.arrow_circle_left_rounded,
                                  color: Colors.black,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xffFAF8F1),
                                  foregroundColor: Colors.black,
                                  child: Text(position.toString()),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
    ));
  }
}

Stream<List<dynamic>> getData() async* {
  final userID = FirebaseAuth.instance.currentUser!.uid;

  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .snapshots()
      .map((snapshot) => snapshot.get('faves'));
}

Future<void> deleteData(int index) async {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  final firestoreInstance = FirebaseFirestore.instance;
  final docRef = firestoreInstance.collection('users').doc(userID);
  final currentArray = (await docRef.get()).data()?['faves'] as List<dynamic>;

  currentArray.removeAt(index);

  await docRef.update({'faves': currentArray});
}
