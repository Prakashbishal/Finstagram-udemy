import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final String USER_COLLECTION = 'users';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map? currentUser;

  FirebaseService();

  // ✅ Register a new user with Cloudinary profile image
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String profileImageUrl, // 👈 Added for image support
  }) async {
    try {
      // Firebase Auth user creation
      UserCredential _userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String _userId = _userCredential.user!.uid;

      // Firestore user document creation
      await _db.collection(USER_COLLECTION).doc(_userId).set({
        "name": name,
        "email": email,
        "image": profileImageUrl, // 👈 Save actual image
      });

      return true;
    } catch (e) {
      print("❌ Registration error: $e");
      return false;
    }
  }

  // ✅ Login existing user
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_userCredential.user != null) {
        currentUser = await getUserData(uid: _userCredential.user!.uid);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Login error: $e");
      return false;
    }
  }

  // ✅ Fetch user data by UID
  Future<Map> getUserData({required String uid}) async {
    DocumentSnapshot _doc =
        await _db.collection(USER_COLLECTION).doc(uid).get();
    return _doc.data() as Map;
  }
}
