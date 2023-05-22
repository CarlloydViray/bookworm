import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bookworm_viraycarlloyd/authGate.dart';
import 'package:bookworm_viraycarlloyd/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.merriweather().fontFamily,
        appBarTheme: const AppBarTheme(color: Color(0XFF025464)),
      ),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
          duration: 3000,
          splashTransition: SplashTransition.scaleTransition,
          splash: const Icon(
            Icons.book_outlined,
            size: 100,
            color: Color(0XFF025464),
          ),
          nextScreen: const authGate()),
    );
  }
}
