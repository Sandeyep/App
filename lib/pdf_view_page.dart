// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// class PdfViewerPage extends StatefulWidget {
//   final String filePath;

//   const PdfViewerPage({super.key, required this.filePath});

//   @override
//   State<PdfViewerPage> createState() => _PdfViewerPageState();
// }

// class _PdfViewerPageState extends State<PdfViewerPage> {
//   bool isReady = false;
//   int totalPages = 0;
//   int currentPage = 0;
//   PDFViewController? controller;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(File(widget.filePath).uri.pathSegments.last)),
//       body: Stack(
//         children: [
//           PDFView(
//             filePath: widget.filePath,
//             enableSwipe: true,
//             swipeHorizontal: false,
//             autoSpacing: true,
//             pageFling: true,
//             key: UniqueKey(), // prevents blank issues
//             onRender: (pages) {
//               setState(() {
//                 totalPages = pages!;
//                 isReady = true;
//               });
//             },
//             onViewCreated: (PDFViewController vc) {
//               controller = vc;
//             },
//             onPageChanged: (page, _) {
//               setState(() {
//                 currentPage = page!;
//               });
//             },
//             onError: (error) {
//               debugPrint("PDFView error: $error");
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("Error loading PDF: $error")),
//               );
//             },
//           ),
//           if (!isReady) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//       bottomNavigationBar: isReady
//           ? Container(
//               padding: const EdgeInsets.all(12),
//               color: Colors.grey.shade200,
//               child: Text(
//                 "Page ${currentPage + 1} of $totalPages",
//                 textAlign: TextAlign.center,
//               ),
//             )
//           : null,
//     );
//   }
// }
