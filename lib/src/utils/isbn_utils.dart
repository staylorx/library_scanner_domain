import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Utility functions for ISBN handling and validation.

/// Determines the BookIdType for an ISBN based on its length.
BookIdType? getIsbnIdType(String isbn) {
  if (isbn.length == 10) {
    return BookIdType.isbn;
  } else if (isbn.length == 13) {
    return BookIdType.isbn13;
  } else {
    return null;
  }
}

/// Validates an ISBN-10 string using regex and checksum.
bool isValidISBN10(String code) {
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
bool isValidISBN13(String code) {
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
