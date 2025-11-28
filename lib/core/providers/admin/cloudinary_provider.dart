import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CloudinaryProvider with ChangeNotifier {
  // Make sure your .env file has CLOUD_NAME (no quotes)
  final String cloudName = dotenv.env['CLOUD_NAME'] ?? '';
  final String uploadPreset = "flutter_unsigned";

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  /// Upload a single image to Cloudinary
  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    _isUploading = true;
    notifyListeners();

    final mimeType = lookupMimeType(imageFile.path);
    final uploadUrl =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = uploadPreset;

    if (folder != null && folder.trim().isNotEmpty) {
      request.fields['folder'] = folder.trim();
    }

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    ));

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final url = RegExp('"secure_url":"(.*?)"')
            .firstMatch(responseData.body)
            ?.group(1)
            ?.replaceAll(r'\/', '/');
        return url;
      } else {
        debugPrint("Upload failed: ${responseData.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading: $e");
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Upload multiple images and return a list of URLs
  Future<List<String>> uploadMultipleImages(List<File> imageFiles,
      {required String folder}) async {
    _isUploading = true;
    notifyListeners();

    List<String> urls = [];

    try {
      for (var imageFile in imageFiles) {
        final url = await uploadImage(imageFile, folder: folder);
        if (url != null) {
          urls.add(url);
        }
      }
      return urls;
    } catch (e) {
      log("Error while upload $e");
      return urls;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
