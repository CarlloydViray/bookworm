import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:quickalert/quickalert.dart';

class menuScreen extends StatefulWidget {
  const menuScreen({super.key});

  @override
  State<menuScreen> createState() => _menuScreenState();
}

class _menuScreenState extends State<menuScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffC58940),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: CircleAvatar(
                backgroundColor: Color(0xFFF4EEE0),
                radius: 50,
                child: Icon(
                  Icons.person,
                  color: Color(0xFF393646),
                  size: 50,
                ),
              )),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  ZoomDrawer.of(context)!.close();
                },
                iconColor: const Color(0xFFF4EEE0),
                textColor: const Color(0xFFF4EEE0),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      title: 'Logout?',
                      onConfirmBtnTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                        ZoomDrawer.of(context)!.close();
                      });
                },
                iconColor: const Color(0xFFF4EEE0),
                textColor: const Color(0xFFF4EEE0),
              ),
            ]),
      ),
    );
  }
}
