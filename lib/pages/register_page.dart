import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseService _firebaseService = FirebaseService();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploading = true);

      final cloudinary = CloudinaryService();
      final uploadedUrl = await cloudinary.uploadImage(pickedFile.path);

      if (uploadedUrl != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImageUrl = uploadedUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to upload profile picture")),
        );
      }

      setState(() => _isUploading = false);
    }
  }

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and upload an image")),
      );
      return;
    }

    setState(() => _isUploading = true);

    final success = await _firebaseService.registerUser(
      name: name,
      email: email,
      password: password,
      profileImageUrl: _uploadedImageUrl!,
    );

    setState(() => _isUploading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Registration successful")));
      Navigator.pop(context); // or navigate to home
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _uploadedImageUrl != null
                        ? NetworkImage(_uploadedImageUrl!)
                        : _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : AssetImage("assets/default_profile.png"),
                child:
                    _uploadedImageUrl == null && _selectedImage == null
                        ? Icon(Icons.add_a_photo, size: 30)
                        : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _registerUser,
                  child: Text("Register"),
                ),
          ],
        ),
      ),
    );
  }
}
