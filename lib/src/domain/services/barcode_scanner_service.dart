import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for barcode scanning operations.
abstract class AbstractBarcodeScannerService {
  /// Initializes the barcode scanner.
  Future<Either<Failure, void>> initialize();

  /// Starts scanning for barcodes and returns the scanned code if successful.
  Future<Either<Failure, String?>> startScanning();

  /// Stops the barcode scanning process.
  Future<Either<Failure, void>> stopScanning();

  /// Disposes of the barcode scanner resources.
  void dispose();
}
