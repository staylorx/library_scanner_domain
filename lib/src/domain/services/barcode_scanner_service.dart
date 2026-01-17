import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for barcode scanning operations.
abstract class BarcodeScannerService {
  /// Starts scanning for barcodes and returns the scanned code if successful.
  Future<Either<Failure, String?>> startScanning();

  /// Stops the barcode scanning process.
  Future<Either<Failure, Unit>> stopScanning();
}
