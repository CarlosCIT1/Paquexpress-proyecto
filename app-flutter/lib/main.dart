import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
// flutter run -d chrome --web-renderer html
void main() => runApp(const PaquexpressApp());

class PaquexpressApp extends StatelessWidget {
  const PaquexpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Paquexpress',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        useMaterial3: true,
      ),
      home: LoginScreen(), 
    );
  }
}