import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class FlutterImageService implements ImageService {
  final Dio _dio;
  final ImagePicker _imagePicker;

  FlutterImageService(this._dio) : _imagePicker = ImagePicker();

  @override
  Future<Either<Failure, String?>> pickFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      return Right(pickedFile?.path);
    } catch (e) {
      return Left(ServiceFailure('Failed to pick image from gallery: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> pickFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      return Right(pickedFile?.path);
    } catch (e) {
      return Left(ServiceFailure('Failed to pick image from camera: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> downloadImageFromUrl({
    required String url,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        // In Flutter, you might want to save to temp directory
        // For this example, return null (path not implemented)
        return const Right(null);
      } else {
        return Left(
          NetworkFailure('Failed to download image: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(NetworkFailure('Error downloading image: $e'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadImageBytesFromUrl({
    required String url,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        return Right(response.data as Uint8List);
      } else {
        return Left(
          NetworkFailure(
            'Failed to download image bytes: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      return Left(NetworkFailure('Error downloading image bytes: $e'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> generateThumbnail({
    required Uint8List imageBytes,
    int maxWidth = 100,
    int maxHeight = 100,
  }) async {
    // For simplicity, return the original bytes
    // In a real implementation, use image package to resize
    return Right(imageBytes);
  }
}
