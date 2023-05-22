import 'package:bookworm_viraycarlloyd/screens/registerScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:quickalert/quickalert.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var obscurePassword = true;

  void login() async {
    if (_formkey.currentState!.validate()) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: 'Checking user credentials...');

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((value) => Navigator.pop(context))
          .catchError((err) {
        print(err.code);
        if (err.code == 'user-not-found') {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'User does not exist!');
        }
        if (err.code == 'wrong-password') {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Incorrect Password!');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('LOGIN'),
          ),
          body: Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.red,
                  ),

                  //email
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*Required. Please enter an email address.';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),

                  //password
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*Required. Please enter your password.';
                      }
                      if (value.length <= 6) {
                        return 'Password must be more than 6 characters';
                      }
                      return null;
                    },
                    obscureText: obscurePassword,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) {
                          return const registerScreen();
                        }),
                      );
                    },
                    child: const Text('Register new account'),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
