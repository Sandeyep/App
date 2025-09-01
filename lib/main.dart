import 'package:flutter/material.dart';

import 'dashboard.dart';

void main() {
  runApp(const SmartPDFApp());
}

class SmartPDFApp extends StatelessWidget {
  const SmartPDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart PDF Tools',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
      ),
      home: const Dashboard(initialIndex: 0, initialRecent: []),
    );
  }
}
