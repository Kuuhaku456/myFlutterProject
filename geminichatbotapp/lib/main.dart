import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geminichatbotapp/controller/api.dart';
import 'package:geminichatbotapp/controller/chat_provider.dart';
import 'package:geminichatbotapp/controller/theme_provider.dart';
import 'package:geminichatbotapp/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeProvider.currentTheme,
          debugShowCheckedModeBanner: false,
          home: MyHomePage(), // Your HomePage widget
        );
      },
    );
  }
}
