import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class AbstractImageService {
  /// Picks an image from the gallery.
  Future<Either<Failure, String?>> pickFromGallery();

  /// Picks an image from the camera.
  Future<Either<Failure, String?>> pickFromCamera();

  /// Downloads an image from the given URL.
  Future<Either<Failure, String?>> downloadImageFromUrl({required String url});

  /// Downloads image bytes from the given URL.
  Future<Either<Failure, Uint8List>> downloadImageBytesFromUrl({
    required String url,
  });

  /// Generates a thumbnail from the given image bytes.
  Future<Either<Failure, Uint8List>> generateThumbnail({
    required Uint8List imageBytes,
    int maxWidth,
    int maxHeight,
  });
}
