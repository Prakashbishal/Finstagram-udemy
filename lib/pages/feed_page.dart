import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FeedPageState();
  }
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(
              child: Text(
                "No posts yet",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;

              final imageUrl = data['image_url'] ?? '';
              final caption = data['caption'] ?? '';
              final email = data['email'] ?? '';
              final timestamp = data['timestamp'] as Timestamp;
              final formattedTime = DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(timestamp.toDate());

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: Center(child: Icon(Icons.broken_image)),
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(caption, style: TextStyle(fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "By: $email",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
