import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../AppColors.dart';

class PdfUpload extends StatefulWidget {
  final Function(List<String>) onFilesSelected;

  const PdfUpload({Key? key, required this.onFilesSelected}) : super(key: key);

  @override
  _PdfUploadState createState() => _PdfUploadState();
}

class _PdfUploadState extends State<PdfUpload> {
  List<String> _pdfFilePaths = []; // Store uploaded file paths

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict to PDF files
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFilePaths.add(result.files.single.path!); // Add file to the list
      });
      widget.onFilesSelected(_pdfFilePaths); // Notify parent widget
    }
  }

  void _removeFile(int index) {
    setState(() {
      _pdfFilePaths.removeAt(index); // Remove file from the list
    });
    widget.onFilesSelected(_pdfFilePaths); // Notify parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pdfFilePaths.isEmpty) ...[
          GestureDetector(
            onTap: _pickPdfFile,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                border: Border.all(color:AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 40, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  const Text(
                    'Click here to upload a PDF',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Column(
            children: _pdfFilePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final filePath = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          border: Border.all(color:AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color:AppColors.errorBackground),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                filePath.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color:AppColors.errorBackground),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickPdfFile, // Add another PDF
            icon: const Icon(Icons.add),
            label: const Text('Add another PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor:AppColors.primary,
              foregroundColor:AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
