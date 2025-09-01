import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:reorderables/reorderables.dart';
import 'package:sewapdf/dashboard.dart';

void main() {
  runApp(
    MaterialApp(
      home: ImageToPDFPage(
        existingRecent: const [],
        onPdfCreated: (List<Map<String, String>> newFiles) {},
      ),
    ),
  );
}

class ImageToPDFPage extends StatefulWidget {
  const ImageToPDFPage({
    super.key,
    required List<Map<String, String>> existingRecent,
    required void Function(List<Map<String, String>> newFiles) onPdfCreated,
  });

  @override
  State<ImageToPDFPage> createState() => _ImageToPDFPageState();
}

class _ImageToPDFPageState extends State<ImageToPDFPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  int? _selectedIndexForChange;

  @override
  void initState() {
    super.initState();
    _pickImages();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages = images);
    }
  }

  Future<void> _addMoreImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<void> _changeSingleImage() async {
    if (_selectedIndexForChange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tap the number on an image to select it"),
        ),
      );
      return;
    }
    final imgFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imgFile != null) {
      setState(() => _selectedImages[_selectedIndexForChange!] = imgFile);
      _selectedIndexForChange = null;
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
    if (_selectedIndexForChange != null && _selectedIndexForChange == index) {
      _selectedIndexForChange = null;
    }
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, item);
    });
  }

  void _goNextPage() {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select images first")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllImagesPreviewPage(images: _selectedImages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image to PDF"),
        actions: [
          if (_selectedImages.isNotEmpty)
            TextButton(
              onPressed: _goNextPage,
              child: const Text("NEXT", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? const Center(child: Text("No images selected"))
          : Padding(
              padding: const EdgeInsets.all(10),
              child: ReorderableWrap(
                spacing: 8,
                runSpacing: 8,
                onReorder: _reorderImages,
                needsLongPressDraggable: true,
                children: List.generate(_selectedImages.length, (index) {
                  return Stack(
                    key: ValueKey(_selectedImages[index].path),
                    children: [
                      Container(
                        width: 110,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedIndexForChange == index
                                ? Colors.orange
                                : Colors.deepPurple,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImages[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndexForChange = index);
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: _selectedIndexForChange == index
                                ? Colors.orange
                                : Colors.black54,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _changeSingleImage,
              icon: const Icon(Icons.swap_horiz),
              label: const Text("Change Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addMoreImages,
              icon: const Icon(Icons.add),
              label: const Text("Add More"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview & PDF Export Page
class AllImagesPreviewPage extends StatefulWidget {
  final List<XFile> images;
  const AllImagesPreviewPage({super.key, required this.images});

  @override
  State<AllImagesPreviewPage> createState() => _AllImagesPreviewPageState();
}

class _AllImagesPreviewPageState extends State<AllImagesPreviewPage> {
  String imageQuality = "High";
  bool _loading = false;
  Uint8List? _pdfBytes;
  String? _fileName;

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    for (var imgFile in widget.images) {
      Uint8List bytes = await File(imgFile.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        int quality = imageQuality == "Low"
            ? 30
            : imageQuality == "Medium"
            ? 60
            : 90;
        bytes = Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
      }
      final image = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(build: (context) => pw.Center(child: pw.Image(image))),
      );
    }

    return pdf.save();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;

      final result = await Permission.manageExternalStorage.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> _downloadPDF() async {
    if (_pdfBytes == null || _fileName == null) return;

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
      return;
    }

    try {
      Directory downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        downloadDir = Directory('${dir.path}/Downloads');
        if (!await downloadDir.exists())
          await downloadDir.create(recursive: true);
      }

      final filePath = '${downloadDir.path}/$_fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(_pdfBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF downloaded: $filePath"),
          duration: const Duration(seconds: 5),
        ),
      );

      // Redirect to RecentPage with the downloaded PDF
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(
            initialRecent: [
              {"pdfPath": filePath, "imagePath": widget.images.first.path},
            ],
            initialIndex: 1, // 👈 open Recent tab directly
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error downloading PDF: $e")));
    }
  }

  Future<void> _convertToPDF(String fileName) async {
    setState(() {
      _loading = true;
      _fileName = fileName;
    });
    try {
      final bytes = await _generatePDF();
      setState(() {
        _pdfBytes = bytes;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ PDF generated successfully! Tap download icon."),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating PDF: $e")));
    }
  }

  void _showConvertDialog() {
    String quality = imageQuality;
    String fileName = "Document_${DateTime.now().millisecondsSinceEpoch}";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("PDF Settings"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: fileName),
                  decoration: const InputDecoration(labelText: "File Name"),
                  onChanged: (val) => fileName = val,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["Low", "Medium", "High"].map((q) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: q,
                          groupValue: quality,
                          onChanged: (val) => setState(() => quality = val!),
                        ),
                        Text(q),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  imageQuality = quality;
                  Navigator.pop(context);
                  _convertToPDF(fileName);
                },
                child: const Text("Generate PDF"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Images Preview"),
        actions: [
          if (_pdfBytes != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPDF,
              tooltip: "Download PDF",
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) => Image.file(
                      File(widget.images[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _showConvertDialog,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Generate PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
