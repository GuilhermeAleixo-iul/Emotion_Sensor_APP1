// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_session_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScanSessionCollectionCollection on Isar {
  IsarCollection<ScanSessionCollection> get scanSessionCollections =>
      this.collection();
}

const ScanSessionCollectionSchema = CollectionSchema(
  name: r'ScanSessionCollection',
  id: -3778861466776021077,
  properties: {
    r'startTime': PropertySchema(
      id: 0,
      name: r'startTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _scanSessionCollectionEstimateSize,
  serialize: _scanSessionCollectionSerialize,
  deserialize: _scanSessionCollectionDeserialize,
  deserializeProp: _scanSessionCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'sensorData': LinkSchema(
      id: 6994273860091493632,
      name: r'sensorData',
      target: r'SensorDataCollection',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _scanSessionCollectionGetId,
  getLinks: _scanSessionCollectionGetLinks,
  attach: _scanSessionCollectionAttach,
  version: '3.1.8',
);

int _scanSessionCollectionEstimateSize(
  ScanSessionCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _scanSessionCollectionSerialize(
  ScanSessionCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.startTime);
}

ScanSessionCollection _scanSessionCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScanSessionCollection();
  object.id = id;
  object.startTime = reader.readDateTime(offsets[0]);
  return object;
}

P _scanSessionCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scanSessionCollectionGetId(ScanSessionCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scanSessionCollectionGetLinks(
    ScanSessionCollection object) {
  return [object.sensorData];
}

void _scanSessionCollectionAttach(
    IsarCollection<dynamic> col, Id id, ScanSessionCollection object) {
  object.id = id;
  object.sensorData.attach(
      col, col.isar.collection<SensorDataCollection>(), r'sensorData', id);
}

extension ScanSessionCollectionQueryWhereSort
    on QueryBuilder<ScanSessionCollection, ScanSessionCollection, QWhere> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScanSessionCollectionQueryWhere on QueryBuilder<ScanSessionCollection,
    ScanSessionCollection, QWhereClause> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterWhereClause>
      idBetween(
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
}

extension ScanSessionCollectionQueryFilter on QueryBuilder<
    ScanSessionCollection, ScanSessionCollection, QFilterCondition> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ScanSessionCollectionQueryObject on QueryBuilder<
    ScanSessionCollection, ScanSessionCollection, QFilterCondition> {}

extension ScanSessionCollectionQueryLinks on QueryBuilder<ScanSessionCollection,
    ScanSessionCollection, QFilterCondition> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorData(FilterQuery<SensorDataCollection> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'sensorData');
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorDataLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', length, true, length, true);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', 0, true, 0, true);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', 0, false, 999999, true);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorDataLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', 0, true, length, include);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorDataLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', length, include, 999999, true);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection,
      QAfterFilterCondition> sensorDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'sensorData', lower, includeLower, upper, includeUpper);
    });
  }
}

extension ScanSessionCollectionQuerySortBy
    on QueryBuilder<ScanSessionCollection, ScanSessionCollection, QSortBy> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension ScanSessionCollectionQuerySortThenBy
    on QueryBuilder<ScanSessionCollection, ScanSessionCollection, QSortThenBy> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension ScanSessionCollectionQueryWhereDistinct
    on QueryBuilder<ScanSessionCollection, ScanSessionCollection, QDistinct> {
  QueryBuilder<ScanSessionCollection, ScanSessionCollection, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension ScanSessionCollectionQueryProperty on QueryBuilder<
    ScanSessionCollection, ScanSessionCollection, QQueryProperty> {
  QueryBuilder<ScanSessionCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScanSessionCollection, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
