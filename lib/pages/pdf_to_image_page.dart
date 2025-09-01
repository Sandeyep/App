import 'package:flutter/material.dart';

class PDFToImagePage extends StatelessWidget {
  const PDFToImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF to Image")),
      body: const Center(
        child: Text("PDF to Image Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
