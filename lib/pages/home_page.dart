import 'package:finstagram/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finstagram/pages/feed_page.dart';
import 'package:finstagram/pages/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finstagram/services/cloudinary_service.dart'; // your helper

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [FeedPage(), ProfilePage()];

  void _logoutUser() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Logged out successfully")));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _uploadPost() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    String? caption = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController _captionController = TextEditingController();
        return AlertDialog(
          title: Text("Enter Caption"),
          content: TextField(
            controller: _captionController,
            decoration: InputDecoration(hintText: "Say something..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed:
                  () =>
                      Navigator.of(context).pop(_captionController.text.trim()),
              child: Text("Post"),
            ),
          ],
        );
      },
    );

    if (caption == null || caption.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Upload cancelled")));
      return;
    }

    final imageUrl = await CloudinaryService().uploadImage(pickedFile.path);

    if (imageUrl != null) {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final email = user?.email;

      if (uid != null && email != null) {
        await FirebaseFirestore.instance.collection('posts').add({
          "user_id": uid,
          "email": email,
          "caption": caption,
          "image_url": imageUrl,
          "timestamp": Timestamp.now(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Post uploaded")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to upload image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finstagram"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logoutUser)],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPost,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
