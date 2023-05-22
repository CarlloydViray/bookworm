import 'package:bookworm_viraycarlloyd/authGate.dart';
import 'package:bookworm_viraycarlloyd/screens/menuScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class drawerScreen extends StatefulWidget {
  const drawerScreen({super.key});

  @override
  State<drawerScreen> createState() => _drawerScreenState();
}

class _drawerScreenState extends State<drawerScreen> {
  final zoomDrawerController = ZoomDrawerController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZoomDrawer(
        menuScreen: const menuScreen(),
        mainScreen: const authGate(),
        menuBackgroundColor: const Color(0xffC58940),
        controller: zoomDrawerController,
        clipMainScreen: false,
        showShadow: true,
        shadowLayer1Color: const Color(0xffE5BA73),
        shadowLayer2Color: const Color(0xffFAEAB1),
        style: DrawerStyle.defaultStyle,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.bounceIn,
      ),
    );
  }
}
