import 'package:bookworm_viraycarlloyd/authGate.dart';
import 'package:bookworm_viraycarlloyd/screens/mainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class registerScreen extends StatefulWidget {
  const registerScreen({super.key});

  @override
  State<registerScreen> createState() => _registerScreenState();
}

class _registerScreenState extends State<registerScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpassController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  var obscurePassword = true;
  final _formkey = GlobalKey<FormState>();
  final collectionPath = 'users';

  void registerClient() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential.user == null) {
        throw FirebaseAuthException(code: 'null-usercredential');
      }
      String uid = userCredential.user!.uid;
      FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(uid)
          .set({'faves': []});
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) {
            return const mainScreen();
          },
        ),
      );
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'weak-password') {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title:
                'Your password is weak. Please enter more than 6 characters.');
        return;
      }
      if (ex.code == 'email-already-in-use') {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title:
                'Your email is already registered. Please enter a new email address.');
        return;
      }
      if (ex.code == 'null-usercredential') {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'An error occured while creating your account. Try again.');
      }

      print(ex.code);
    }
  }

  void validateInput() {
    if (_formkey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: null,
        confirmBtnText: 'Yes',
        cancelBtnText: 'Cancel',
        onConfirmBtnTap: () {
          Navigator.pop(context);
          registerClient();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Register account',
            style: TextStyle(color: Color(0xFFF4EEE0)),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFF4EEE0),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),

                    const SizedBox(
                      height: 12.0,
                    ),
                    //email
                    TextFormField(
                      focusNode: _focusNode,
                      onFieldSubmitted: (value) {
                        _focusNode.unfocus();
                        validateInput();
                      },
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
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(
                            color: Colors.black,
                          )),
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
                      focusNode: _focusNode2,
                      onFieldSubmitted: (value) {
                        _focusNode2.unfocus();
                        validateInput();
                      },
                      obscureText: obscurePassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: const TextStyle(color: Colors.black),
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
                    const SizedBox(
                      height: 12.0,
                    ),

                    //confirm password
                    TextFormField(
                      onFieldSubmitted: (value) {
                        _focusNode3.unfocus();
                        validateInput();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Required. Please enter your password.';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords don\'t match';
                        }
                        return null;
                      },
                      focusNode: _focusNode3,
                      obscureText: obscurePassword,
                      controller: confirmpassController,
                      decoration: const InputDecoration(
                        labelText: 'Re-type Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: validateInput,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffC58940),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
