import 'package:flutter/material.dart';

class AnnotatePDFPage extends StatelessWidget {
  const AnnotatePDFPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Annotate PDF")),
      body: const Center(
        child: Text("Annotate PDF Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
