import 'package:flutter/material.dart';

class SplitPDFsPage extends StatelessWidget {
  const SplitPDFsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Split PDFs")),
      body: const Center(
        child: Text("Split PDFs Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
