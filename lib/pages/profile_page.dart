import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _db.collection('users').doc(uid).get();
      setState(() {
        userData = doc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body:
          userData == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData!['image']),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData!['name'] ?? '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData!['email'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          _db
                              .collection('posts')
                              .where('user_id', isEqualTo: uid)
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(child: CircularProgressIndicator());

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                          return Center(
                            child: Text(
                              "No posts yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );

                        final posts = snapshot.data!.docs;

                        return GridView.builder(
                          padding: EdgeInsets.all(12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            final imageUrl = post['image_url'];

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.broken_image, size: 30),
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
