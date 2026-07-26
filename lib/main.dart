import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HudumaReceiptPro());
}

class HudumaReceiptPro extends StatelessWidget {
  const HudumaReceiptPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Huduma Receipt Pro',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
