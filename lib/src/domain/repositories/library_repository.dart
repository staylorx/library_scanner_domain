import 'package:fpdart/fpdart.dart';
import '../entities/import_result.dart';
import '../entities/library.dart';
import '../../utils/failure.dart';

// library is the heart of the application, a collection of books
// Authors and tags are "global" to all libraries
// This repository defines the contract for accessing library data
// It includes methods to retrieve a demo library, import a library from a file, export a library to a file, and clear the library
abstract class ILibraryRepository {
  Future<Either<Failure, ImportResult>> importLibrary(
    String filePath, {
    bool overwrite = false,
  });
  Future<Either<Failure, Unit>> exportLibrary({
    required String filePath,
    required Library library,
  });
  Future<Either<Failure, Unit>> clearLibrary();
}
