import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'api_client.dart';

/// Backend upload endpoint'lari bilan ishlaydigan service.
///
/// Endpointlar (`backend/app/api/v1/upload.py` — Sprint 4'da):
/// - `POST /uploads/avatar`        (`multipart`)
/// - `POST /uploads/post-image`
/// - `POST /uploads/gallery-image`
///
/// Backend MinIO ga yuklab, public URL'ni qaytaradi.
class FileService {
  FileService._();

  static final _api = ApiClient.instance;

  // Folder konvensiyalari (backend ham bir xil ishlatadi)
  static const String folderUserImg = 'avatar';
  static const String folderPostImg = 'post-image';
  static const String folderGallery = 'gallery-image';

  /// Bitta faylni yuklab, public URL qaytaradi.
  static Future<String> uploadFile(File file, String folder) async {
    final fileName = p.basename(file.path);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _api.dio.post<Map<String, dynamic>>(
      '/uploads/$folder',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    return response.data!['url'] as String;
  }

  /// Bir necha faylni parallel yuklab, URL ro'yxatini qaytaradi.
  static Future<List<String>> uploadFiles(
    List<File> files,
    String folder,
  ) async {
    return Future.wait(files.map((f) => uploadFile(f, folder)));
  }
}
