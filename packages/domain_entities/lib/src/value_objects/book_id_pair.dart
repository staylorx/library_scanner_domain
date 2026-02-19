import 'package:domain_entities/domain_entities.dart';
import 'package:equatable/equatable.dart';
import 'package:id_registry/id_registry.dart';

// idPairs are used to represent a combination of an ID type and a business code ID code
// this is not the same thing as our internal database ID of a book
class BookIdPair with EquatableMixin implements IdPair {
  @override
  final BookIdType idType;
  @override
  final String idCode;

  const BookIdPair({required this.idType, required this.idCode});

  // local is anything we come up with ourselves, so always valid
  @override
  bool get isValid {
    switch (idType) {
      case BookIdType.isbn10:
        return isValidISBN10(code: idCode);
      case BookIdType.isbn13:
        return isValidISBN13(code: idCode);
      case BookIdType.asin:
        return isValidASIN(code: idCode);
      case BookIdType.doi:
        return isValidDOI(code: idCode);
      case BookIdType.ean:
        return isValidEAN(code: idCode);
      case BookIdType.upc:
        return isValidUPC(code: idCode);
      case BookIdType.local:
        return true;
    }
  }

  @override
  String get displayName => idType.displayName;

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return BookIdPair(
      idType: (idType as BookIdType?) ?? this.idType,
      idCode: idCode ?? this.idCode,
    );
  }

  @override
  List<Object?> get props => [idType, idCode];
}
