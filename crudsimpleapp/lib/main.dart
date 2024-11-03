import 'dart:io';
import 'package:crudsimpleapp/android/controller/anime_controller.dart';
import 'package:crudsimpleapp/android/mobile.dart';
import 'package:crudsimpleapp/windows/windows.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AnimeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return const DesktopApp();
    } else {
      return const MobileApp();
    }
  }
}



