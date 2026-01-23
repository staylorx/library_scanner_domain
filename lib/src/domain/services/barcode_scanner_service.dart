import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Abstract service for barcode scanning operations.
abstract class BarcodeScannerService {
  /// Starts scanning for barcodes and returns the scanned code if successful.
  TaskEither<Failure, String?> startScanning();

  /// Stops the barcode scanning process.
  TaskEither<Failure, Unit> stopScanning();
}
