import 'package:aplikasi_absensi/login_page.dart';
import 'package:aplikasi_absensi/register_page.dart';
import 'package:aplikasi_absensi/welcome_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      // home: const WelcomePage(),
      routes: {
        "/": (context) => const WelcomePage(),
        // WelcomePage.id: (context) => const WelcomePage(),
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: RegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
