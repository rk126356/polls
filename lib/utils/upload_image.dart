import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  // Replace these values with your Cloudinary credentials
  final cloudinary = CloudinaryPublic('dt6hd2ofm', 'resize');

  try {
    CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(imageFile.path,
          resourceType: CloudinaryResourceType.Image),
    );

    return response.secureUrl;
  } on CloudinaryException catch (e) {
    print(e.message);
    print(e.request);
    return null;
  }
}
