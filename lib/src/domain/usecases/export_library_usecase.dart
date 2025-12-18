import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import '../entities/library.dart';
import '../repositories/library_repository.dart';

/// Use case for exporting a library to a file.
class ExportLibraryUsecase {
  final ILibraryRepository libraryRepository;

  ExportLibraryUsecase(this.libraryRepository);

  final logger = DevLogger('ExportLibraryUsecase');

  /// Exports the library to the specified file path.
  Future<Either<Failure, Unit>> call({
    required String filePath,
    required Library library,
  }) async {
    logger.info('ExportLibraryUsecase: Exporting library to $filePath');
    final result = await libraryRepository.exportLibrary(
      filePath: filePath,
      library: library,
    );
    result.fold(
      (failure) => logger.error(
        'ExportLibraryUsecase: Failed to export library: ${failure.message}',
      ),
      (_) => logger.info('ExportLibraryUsecase: Successfully exported library'),
    );
    return result;
  }
}
