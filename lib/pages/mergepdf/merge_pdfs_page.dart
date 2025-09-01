import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MergePDFsPage extends StatefulWidget {
  const MergePDFsPage({super.key});

  @override
  State<MergePDFsPage> createState() => _MergePDFsPageState();
}

class _MergePDFsPageState extends State<MergePDFsPage> {
  List<File> selectedPDFs = [];

  Future<void> pickPDFs() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedPDFs = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> mergePDFs() async {
    if (selectedPDFs.isEmpty) return;

    final pdf = pw.Document();

    for (var file in selectedPDFs) {
      final bytes = await file.readAsBytes();
      final pdfDoc = pw.Document();
      pdfDoc.addPage(
        pw.Page(build: (context) => pw.Center()),
      ); // avoid empty doc error
      final tempDoc = pw.Document();
      tempDoc.addPage(pw.Page(build: (context) => pw.Center()));

      try {
        final pdfImage = pw.MemoryImage(bytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.Center(child: pw.Image(pdfImage)),
          ),
        );
      } catch (e) {
        debugPrint("Skipping ${file.path}, not valid PDF");
      }
    }

    final outputDir = await getExternalStorageDirectory();
    final outputFile = File("${outputDir!.path}/merged.pdf");
    await outputFile.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Merged PDF saved at ${outputFile.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Merge PDFs")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: pickPDFs, child: const Text("Select PDFs")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: mergePDFs, child: const Text("Merge PDFs")),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: selectedPDFs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(selectedPDFs[index].path.split('/').last),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
