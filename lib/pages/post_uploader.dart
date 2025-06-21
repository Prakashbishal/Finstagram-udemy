import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';

class PostUploader extends StatefulWidget {
  @override
  _PostUploaderState createState() => _PostUploaderState();
}

class _PostUploaderState extends State<PostUploader> {
  File? _selectedImage;
  final picker = ImagePicker();
  final captionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null || captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image and add a caption.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final cloudinary = CloudinaryService();
    final imageUrl = await cloudinary.uploadImage(_selectedImage!.path);

    if (imageUrl != null) {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('posts').add({
        'image_url': imageUrl,
        'caption': captionController.text.trim(),
        'user_id': user?.uid,
        'email': user?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Post uploaded successfully!")),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to upload image.")));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, height: 200),
                )
                : Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text("No image selected.")),
                ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text("Pick Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: captionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Write a caption...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Text(
                          "Upload Post",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
