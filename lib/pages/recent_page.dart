import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart'; // ✅ use open_filex instead of open_file
import 'package:share_plus/share_plus.dart';

class RecentPage extends StatefulWidget {
  final List<Map<String, String>> pdfFiles;

  const RecentPage({
    super.key,
    required this.pdfFiles,
    required void Function(List<Map<String, String>> updatedFiles) onPdfDeleted,
  });

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  late List<Map<String, String>> pdfFiles;

  @override
  void initState() {
    super.initState();
    pdfFiles = List.from(widget.pdfFiles);
  }

  Future<void> openPdf(String pdfPath) async {
    final result = await OpenFilex.open(pdfPath); // ✅ use OpenFilex

    if (result.type != ResultType.done) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open PDF: ${result.message}")),
      );
    }
  }

  void deletePdf(int index) {
    final pdfPath = pdfFiles[index]["pdfPath"]!;
    final imagePath = pdfFiles[index]["imagePath"]!;

    try {
      final pdfFile = File(pdfPath);
      final imageFile = File(imagePath);

      if (pdfFile.existsSync()) pdfFile.deleteSync();
      if (imageFile.existsSync()) imageFile.deleteSync();

      setState(() {
        pdfFiles.removeAt(index);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PDF deleted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete PDF: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pdfFiles.isEmpty) {
      return const Scaffold(body: Center(child: Text("No recent PDFs found")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Recent PDFs")),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final pdfPath = pdfFiles[index]["pdfPath"]!;
          final imagePath = pdfFiles[index]["imagePath"]!;
          final file = File(pdfPath);
          final fileName = pdfPath.split('/').last;
          final fileSize =
              "${(file.lengthSync() / 1024).toStringAsFixed(0)} KB";

          final lastModified = file.lastModifiedSync();
          final formattedDate = DateFormat(
            "dd/MM/yyyy-HH:mm",
          ).format(lastModified);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(imagePath),
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Details + buttons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$fileSize\n$formattedDate",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Buttons: Share, Open, Delete
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                icon: const Icon(Icons.share, size: 16),
                                label: const Text(
                                  "Share",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  Share.shareXFiles([
                                    XFile(pdfPath),
                                  ], text: 'Here is your PDF');
                                },
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: TextButton.icon(
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text(
                                  "Open",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () => openPdf(pdfPath),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: TextButton.icon(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                label: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () => deletePdf(index),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
