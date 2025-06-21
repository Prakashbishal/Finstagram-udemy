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
    if (_selectedImage == null || captionController.text.isEmpty) return;

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Post uploaded successfully!")));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to upload image.")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Text("No image selected."),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: Text("Pick Image")),
            SizedBox(height: 10),
            TextField(
              controller: captionController,
              decoration: InputDecoration(labelText: "Caption"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadPost,
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text("Upload Post"),
            ),
          ],
        ),
      ),
    );
  }
}
