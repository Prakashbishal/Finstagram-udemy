import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'dsj7z3tsr',
    'unsigned_finsta',
    cache: false,
  );

  Future<String?> uploadImage(String imagePath) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      print("✅ Upload successful! URL: ${response.secureUrl}");
      return response.secureUrl;
    } catch (e) {
      print("❌ Cloudinary upload error: $e");
      return null;
    }
  }
}
