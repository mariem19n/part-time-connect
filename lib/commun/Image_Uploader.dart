import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../AppColors.dart';

class ImageUploader extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  const ImageUploader({Key? key, required this.onImagesSelected}) : super(key: key);

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  List<File> _uploadedImages = [];
  final ImagePicker _picker = ImagePicker();

  void _addImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _uploadedImages.add(File(pickedFile.path));
      });
      widget.onImagesSelected(_uploadedImages);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
    widget.onImagesSelected(_uploadedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            ..._uploadedImages.asMap().entries.map((entry) {
              int index = entry.key;
              File imageFile = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.file(
                    imageFile,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.errorBackground,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _addImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, size: 30, color: AppColors.borderColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
