import 'package:flutter/material.dart';

class DocxToPDFPage extends StatelessWidget {
  const DocxToPDFPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DOCX to PDF")),
      body: const Center(
        child: Text("DOCX to PDF Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
