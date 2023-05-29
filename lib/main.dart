import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bookworm_viraycarlloyd/firebase_options.dart';
import 'package:bookworm_viraycarlloyd/screens/drawerScreen.dart';
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
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(24),
              ),
            ),
          ),
          fontFamily: GoogleFonts.merriweather().fontFamily,
          appBarTheme: const AppBarTheme(color: Color(0xffC58940)),
          scaffoldBackgroundColor: const Color(0xffFAF8F1),
          cardColor: const Color(0xffE5BA73)),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: AnimatedSplashScreen(
          backgroundColor: const Color(0xffFAF8F1),
          duration: 3000,
          splashTransition: SplashTransition.scaleTransition,
          splash: const CircleAvatar(
            backgroundColor: Color(0xffC58940),
            maxRadius: 800,
            child: Icon(
              Icons.book_outlined,
              size: 50,
              color: Colors.black,
            ),
          ),
          nextScreen: const drawerScreen(),
        ),
      ),
    );
  }
}
