import 'package:flutter/material.dart';
import 'package:gitapp/pages/home_page.dart';
import 'package:gitapp/pages/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GitHub and Image App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,  
    );
  }
}
