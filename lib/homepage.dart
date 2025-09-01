import 'package:flutter/material.dart';

import 'pages/annotate_pdf_page.dart';
import 'pages/docx2pdf/docx_to_pdf_page.dart';
import 'pages/image2pdf/image_to_pdf_page.dart';
import 'pages/mergepdf/merge_pdfs_page.dart';
import 'pages/pdf_to_docx_page.dart';
import 'pages/pdf_to_image_page.dart';
import 'pages/split_pdfs_page.dart';

class Feature {
  final String title;
  final IconData icon;
  final Widget page;

  Feature(this.title, this.icon, this.page);
}

class HomePage extends StatefulWidget {
  final void Function(List<Map<String, String>> newFiles) onPdfCreated;
  final List<Map<String, String>> existingRecent;

  const HomePage({
    super.key,
    required this.onPdfCreated,
    this.existingRecent = const [],
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, String>> recentPDFs;

  @override
  void initState() {
    super.initState();
    recentPDFs = List.from(widget.existingRecent);
  }

  void _updateRecent(List<Map<String, String>> newFiles) {
    setState(() {
      recentPDFs = newFiles;
    });
    widget.onPdfCreated(newFiles); // Notify dashboard
  }

  late final List<Feature> _features;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _features = [
      Feature(
        "Image to PDF",
        Icons.image,
        ImageToPDFPage(existingRecent: recentPDFs, onPdfCreated: _updateRecent),
      ),
      Feature("PDF to Image", Icons.picture_as_pdf, PDFToImagePage()),
      Feature("Merge PDFs", Icons.merge_type, MergePDFsPage()),
      Feature("Split PDFs", Icons.call_split, SplitPDFsPage()),
      Feature("Annotate PDF", Icons.edit, AnnotatePDFPage()),
      Feature("DOCX to PDF", Icons.description, DocxToPDFPage()),
      Feature("PDF to DOCX", Icons.file_present, PDFToDocxPage()),
    ];
  }

  Widget buildFeatureCard(BuildContext context, Feature feature) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => feature.page),
        );
      },
      child: Card(
        color: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(feature.icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                feature.title,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Smart PDF Tools",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: _features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    return buildFeatureCard(context, _features[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
