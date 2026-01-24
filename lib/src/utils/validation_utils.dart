import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Utility functions for ISBN handling and validation.

/// Determines the BookIdType for an ISBN based on its length.
Either<Failure, BookIdType> getIsbnIdType({required String isbn}) {
  if (isValidISBN10(code: isbn)) {
    return Right(BookIdType.isbn10);
  } else if (isValidISBN13(code: isbn)) {
    return Right(BookIdType.isbn13);
  } else {
    return Left(ValidationFailure("Invalid ISBN"));
  }
}

/// Validates an ISBN-10 string using regex and checksum.
bool isValidISBN10({required String code}) {
  if (!RegExp(r'^\d{9}[\dX]$').hasMatch(code)) return false;
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    final digit = int.tryParse(code[i]);
    if (digit == null || digit < 0 || digit > 9) return false;
    sum += digit * (10 - i);
  }
  final last = code[9];
  final check = last == 'X' ? 10 : int.tryParse(last);
  if (check == null || check < 0 || check > 10) return false;
  sum += check;
  return sum % 11 == 0;
}

/// Validates an ISBN-13 string using regex and checksum.
bool isValidISBN13({required String code}) {
  if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    final digit = int.tryParse(code[i]);
    if (digit == null || digit < 0 || digit > 9) return false;
    sum += digit * (i % 2 == 0 ? 1 : 3);
  }
  final check = (10 - (sum % 10)) % 10;
  final last = int.tryParse(code[12]);
  return last == check;
}

bool isValidASIN({required String code}) {
  if (code.length != 10) return false;
  return RegExp(r'^[A-Za-z0-9]{10}$').hasMatch(code);
}

bool isValidDOI({required String code}) {
  return RegExp(r'^10\.[A-Za-z0-9]+$').hasMatch(code);
}

bool isValidEAN({required String code}) {
  return validateLuhn(code: code, isEanStyle: true);
}

/// Validates a UPC string using regex and checksum.
bool isValidUPC({required String code}) {
  return validateLuhn(code: code, isEanStyle: false);
}

/// Validates a code using the Luhn algorithm (for EAN/UPC style).
/// Decent enough for books but has limitations (e.g., not suitable for credit cards).
bool validateLuhn({required String code, bool isEanStyle = false}) {
  // Clean input
  code = code.replaceAll(RegExp(r'[^0-9]'), '');
  if (code.isEmpty || ![8, 12, 13].contains(code.length)) return false;

  int sum = 0;
  final length = code.length;

  // GS1 standard: Right-to-left, position 1=check digit
  for (int i = 0; i < length - 1; i++) {
    final digit = int.parse(code[length - 2 - i]);
    final positionFromRight = i + 1;

    // EAN style: odd positions ×3 (1,3,5...), UPC style: even ×3 (2,4,6...)
    final weight = (positionFromRight % 2 == 1) ^ isEanStyle ? 3 : 1;

    final weighted = digit * weight;
    sum += weighted;
  }

  final checkDigit = int.parse(code[length - 1]);
  return (sum + checkDigit) % 10 == 0;
}
