import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class AbstractImageService {
  Future<Either<Failure, String?>> pickFromGallery();

  Future<Either<Failure, String?>> pickFromCamera();

  Future<Either<Failure, String?>> downloadImageFromUrl(String url);

  Future<Either<Failure, Uint8List>> downloadImageBytesFromUrl(String url);

  Future<Either<Failure, Uint8List>> generateThumbnail(
    Uint8List imageBytes, {
    int maxWidth,
    int maxHeight,
  });
}
