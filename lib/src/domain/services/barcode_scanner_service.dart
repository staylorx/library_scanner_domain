import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

abstract class AbstractBarcodeScannerService {
  Future<Either<Failure, void>> initialize();

  Future<Either<Failure, String?>> startScanning();

  Future<Either<Failure, void>> stopScanning();

  void dispose();
}
