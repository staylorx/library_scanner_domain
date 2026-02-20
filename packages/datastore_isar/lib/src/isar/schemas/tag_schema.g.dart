// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTagSchemaCollection on Isar {
  IsarCollection<TagSchema> get tagSchemas => this.collection();
}

const TagSchemaSchema = CollectionSchema(
  name: r'TagSchema',
  id: -2847478644532369564,
  properties: {
    r'bookIds': PropertySchema(
      id: 0,
      name: r'bookIds',
      type: IsarType.stringList,
    ),
    r'dataJson': PropertySchema(
      id: 1,
      name: r'dataJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'stringId': PropertySchema(
      id: 3,
      name: r'stringId',
      type: IsarType.string,
    )
  },
  estimateSize: _tagSchemaEstimateSize,
  serialize: _tagSchemaSerialize,
  deserialize: _tagSchemaDeserialize,
  deserializeProp: _tagSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'stringId': IndexSchema(
      id: 2631728708659333672,
      name: r'stringId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'stringId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'bookIds': IndexSchema(
      id: -4688737983034392486,
      name: r'bookIds',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookIds',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _tagSchemaGetId,
  getLinks: _tagSchemaGetLinks,
  attach: _tagSchemaAttach,
  version: '3.1.0+1',
);

int _tagSchemaEstimateSize(
  TagSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookIds.length * 3;
  {
    for (var i = 0; i < object.bookIds.length; i++) {
      final value = object.bookIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.dataJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.stringId.length * 3;
  return bytesCount;
}

void _tagSchemaSerialize(
  TagSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.bookIds);
  writer.writeString(offsets[1], object.dataJson);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.stringId);
}

TagSchema _tagSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TagSchema();
  object.bookIds = reader.readStringList(offsets[0]) ?? [];
  object.dataJson = reader.readString(offsets[1]);
  object.name = reader.readString(offsets[2]);
  object.stringId = reader.readString(offsets[3]);
  return object;
}

P _tagSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tagSchemaGetId(TagSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tagSchemaGetLinks(TagSchema object) {
  return [];
}

void _tagSchemaAttach(IsarCollection<dynamic> col, Id id, TagSchema object) {}

extension TagSchemaByIndex on IsarCollection<TagSchema> {
  Future<TagSchema?> getByStringId(String stringId) {
    return getByIndex(r'stringId', [stringId]);
  }

  TagSchema? getByStringIdSync(String stringId) {
    return getByIndexSync(r'stringId', [stringId]);
  }

  Future<bool> deleteByStringId(String stringId) {
    return deleteByIndex(r'stringId', [stringId]);
  }

  bool deleteByStringIdSync(String stringId) {
    return deleteByIndexSync(r'stringId', [stringId]);
  }

  Future<List<TagSchema?>> getAllByStringId(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringId', values);
  }

  List<TagSchema?> getAllByStringIdSync(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'stringId', values);
  }

  Future<int> deleteAllByStringId(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'stringId', values);
  }

  int deleteAllByStringIdSync(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'stringId', values);
  }

  Future<Id> putByStringId(TagSchema object) {
    return putByIndex(r'stringId', object);
  }

  Id putByStringIdSync(TagSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringId(List<TagSchema> objects) {
    return putAllByIndex(r'stringId', objects);
  }

  List<Id> putAllByStringIdSync(List<TagSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'stringId', objects, saveLinks: saveLinks);
  }

  Future<TagSchema?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  TagSchema? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<TagSchema?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<TagSchema?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(TagSchema object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(TagSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<TagSchema> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<TagSchema> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension TagSchemaQueryWhereSort
    on QueryBuilder<TagSchema, TagSchema, QWhere> {
  QueryBuilder<TagSchema, TagSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TagSchemaQueryWhere
    on QueryBuilder<TagSchema, TagSchema, QWhereClause> {
  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> stringIdEqualTo(
      String stringId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stringId',
        value: [stringId],
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> stringIdNotEqualTo(
      String stringId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [],
              upper: [stringId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [stringId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [stringId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [],
              upper: [stringId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> bookIdsEqualTo(
      List<String> bookIds) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookIds',
        value: [bookIds],
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterWhereClause> bookIdsNotEqualTo(
      List<String> bookIds) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookIds',
              lower: [],
              upper: [bookIds],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookIds',
              lower: [bookIds],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookIds',
              lower: [bookIds],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookIds',
              lower: [],
              upper: [bookIds],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TagSchemaQueryFilter
    on QueryBuilder<TagSchema, TagSchema, QFilterCondition> {
  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookIds',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookIds',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> bookIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      bookIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stringId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stringId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition> stringIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringId',
        value: '',
      ));
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterFilterCondition>
      stringIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stringId',
        value: '',
      ));
    });
  }
}

extension TagSchemaQueryObject
    on QueryBuilder<TagSchema, TagSchema, QFilterCondition> {}

extension TagSchemaQueryLinks
    on QueryBuilder<TagSchema, TagSchema, QFilterCondition> {}

extension TagSchemaQuerySortBy on QueryBuilder<TagSchema, TagSchema, QSortBy> {
  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> sortByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> sortByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> sortByStringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> sortByStringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.desc);
    });
  }
}

extension TagSchemaQuerySortThenBy
    on QueryBuilder<TagSchema, TagSchema, QSortThenBy> {
  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByStringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.asc);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QAfterSortBy> thenByStringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.desc);
    });
  }
}

extension TagSchemaQueryWhereDistinct
    on QueryBuilder<TagSchema, TagSchema, QDistinct> {
  QueryBuilder<TagSchema, TagSchema, QDistinct> distinctByBookIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookIds');
    });
  }

  QueryBuilder<TagSchema, TagSchema, QDistinct> distinctByDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagSchema, TagSchema, QDistinct> distinctByStringId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringId', caseSensitive: caseSensitive);
    });
  }
}

extension TagSchemaQueryProperty
    on QueryBuilder<TagSchema, TagSchema, QQueryProperty> {
  QueryBuilder<TagSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TagSchema, List<String>, QQueryOperations> bookIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookIds');
    });
  }

  QueryBuilder<TagSchema, String, QQueryOperations> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataJson');
    });
  }

  QueryBuilder<TagSchema, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TagSchema, String, QQueryOperations> stringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringId');
    });
  }
}
