import 'package:flutter/material.dart';

class PDFToDocxPage extends StatelessWidget {
  const PDFToDocxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF to DOCX")),
      body: const Center(
        child: Text("PDF to DOCX Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
