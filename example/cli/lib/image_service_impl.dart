import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class CliImageService implements ImageService {
  final Dio _dio;

  CliImageService(this._dio);

  @override
  Future<Either<Failure, String?>> pickFromGallery() async {
    // CLI doesn't support picking from gallery
    return const Left(ServiceFailure('Not supported in CLI'));
  }

  @override
  Future<Either<Failure, String?>> pickFromCamera() async {
    // CLI doesn't support picking from camera
    return const Left(ServiceFailure('Not supported in CLI'));
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
        // For CLI, we can save to a temp file or just return a path
        // For simplicity, return null or a placeholder
        return const Right(null); // Or implement file saving
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
