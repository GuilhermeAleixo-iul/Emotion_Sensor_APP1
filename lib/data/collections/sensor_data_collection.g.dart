// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_data_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSensorDataCollectionCollection on Isar {
  IsarCollection<SensorDataCollection> get sensorDataCollections =>
      this.collection();
}

const SensorDataCollectionSchema = CollectionSchema(
  name: r'SensorDataCollection',
  id: -8546089805957937055,
  properties: {
    r'accelX': PropertySchema(
      id: 0,
      name: r'accelX',
      type: IsarType.double,
    ),
    r'grs': PropertySchema(
      id: 1,
      name: r'grs',
      type: IsarType.double,
    ),
    r'ppg': PropertySchema(
      id: 2,
      name: r'ppg',
      type: IsarType.double,
    ),
    r'timeStamp': PropertySchema(
      id: 3,
      name: r'timeStamp',
      type: IsarType.double,
    )
  },
  estimateSize: _sensorDataCollectionEstimateSize,
  serialize: _sensorDataCollectionSerialize,
  deserialize: _sensorDataCollectionDeserialize,
  deserializeProp: _sensorDataCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'timeStamp': IndexSchema(
      id: 1365751510135348298,
      name: r'timeStamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timeStamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'scanSession': LinkSchema(
      id: -5116945741112139267,
      name: r'scanSession',
      target: r'ScanSessionCollection',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _sensorDataCollectionGetId,
  getLinks: _sensorDataCollectionGetLinks,
  attach: _sensorDataCollectionAttach,
  version: '3.1.8',
);

int _sensorDataCollectionEstimateSize(
  SensorDataCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _sensorDataCollectionSerialize(
  SensorDataCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accelX);
  writer.writeDouble(offsets[1], object.grs);
  writer.writeDouble(offsets[2], object.ppg);
  writer.writeDouble(offsets[3], object.timeStamp);
}

SensorDataCollection _sensorDataCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SensorDataCollection(
    accelX: reader.readDoubleOrNull(offsets[0]),
    grs: reader.readDoubleOrNull(offsets[1]),
    ppg: reader.readDoubleOrNull(offsets[2]),
    timeStamp: reader.readDoubleOrNull(offsets[3]),
  );
  object.id = id;
  return object;
}

P _sensorDataCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sensorDataCollectionGetId(SensorDataCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sensorDataCollectionGetLinks(
    SensorDataCollection object) {
  return [object.scanSession];
}

void _sensorDataCollectionAttach(
    IsarCollection<dynamic> col, Id id, SensorDataCollection object) {
  object.id = id;
  object.scanSession.attach(
      col, col.isar.collection<ScanSessionCollection>(), r'scanSession', id);
}

extension SensorDataCollectionQueryWhereSort
    on QueryBuilder<SensorDataCollection, SensorDataCollection, QWhere> {
  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhere>
      anyTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timeStamp'),
      );
    });
  }
}

extension SensorDataCollectionQueryWhere
    on QueryBuilder<SensorDataCollection, SensorDataCollection, QWhereClause> {
  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
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

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
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

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timeStamp',
        value: [null],
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timeStamp',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampEqualTo(double? timeStamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timeStamp',
        value: [timeStamp],
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampNotEqualTo(double? timeStamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timeStamp',
              lower: [],
              upper: [timeStamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timeStamp',
              lower: [timeStamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timeStamp',
              lower: [timeStamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timeStamp',
              lower: [],
              upper: [timeStamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampGreaterThan(
    double? timeStamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timeStamp',
        lower: [timeStamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampLessThan(
    double? timeStamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timeStamp',
        lower: [],
        upper: [timeStamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterWhereClause>
      timeStampBetween(
    double? lowerTimeStamp,
    double? upperTimeStamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timeStamp',
        lower: [lowerTimeStamp],
        includeLower: includeLower,
        upper: [upperTimeStamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SensorDataCollectionQueryFilter on QueryBuilder<SensorDataCollection,
    SensorDataCollection, QFilterCondition> {
  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> accelXIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accelX',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> accelXIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accelX',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> accelXEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accelX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> accelXGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accelX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> accelXLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accelX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> accelXBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accelX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> grsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'grs',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> grsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'grs',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> grsEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> grsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> grsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> grsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
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

  QueryBuilder<SensorDataCollection, SensorDataCollection,
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

  QueryBuilder<SensorDataCollection, SensorDataCollection,
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

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> ppgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ppg',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> ppgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ppg',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> ppgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ppg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> ppgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ppg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> ppgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ppg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> ppgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ppg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> timeStampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timeStamp',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> timeStampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timeStamp',
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> timeStampEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeStamp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> timeStampGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeStamp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> timeStampLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeStamp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> timeStampBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeStamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension SensorDataCollectionQueryObject on QueryBuilder<SensorDataCollection,
    SensorDataCollection, QFilterCondition> {}

extension SensorDataCollectionQueryLinks on QueryBuilder<SensorDataCollection,
    SensorDataCollection, QFilterCondition> {
  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> scanSession(FilterQuery<ScanSessionCollection> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'scanSession');
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection,
      QAfterFilterCondition> scanSessionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'scanSession', 0, true, 0, true);
    });
  }
}

extension SensorDataCollectionQuerySortBy
    on QueryBuilder<SensorDataCollection, SensorDataCollection, QSortBy> {
  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByAccelX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accelX', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByAccelXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accelX', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByGrs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grs', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByGrsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grs', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByPpg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ppg', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByPpgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ppg', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      sortByTimeStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.desc);
    });
  }
}

extension SensorDataCollectionQuerySortThenBy
    on QueryBuilder<SensorDataCollection, SensorDataCollection, QSortThenBy> {
  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByAccelX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accelX', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByAccelXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accelX', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByGrs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grs', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByGrsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grs', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByPpg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ppg', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByPpgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ppg', Sort.desc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.asc);
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QAfterSortBy>
      thenByTimeStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.desc);
    });
  }
}

extension SensorDataCollectionQueryWhereDistinct
    on QueryBuilder<SensorDataCollection, SensorDataCollection, QDistinct> {
  QueryBuilder<SensorDataCollection, SensorDataCollection, QDistinct>
      distinctByAccelX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accelX');
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QDistinct>
      distinctByGrs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grs');
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QDistinct>
      distinctByPpg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ppg');
    });
  }

  QueryBuilder<SensorDataCollection, SensorDataCollection, QDistinct>
      distinctByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeStamp');
    });
  }
}

extension SensorDataCollectionQueryProperty on QueryBuilder<
    SensorDataCollection, SensorDataCollection, QQueryProperty> {
  QueryBuilder<SensorDataCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SensorDataCollection, double?, QQueryOperations>
      accelXProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accelX');
    });
  }

  QueryBuilder<SensorDataCollection, double?, QQueryOperations> grsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grs');
    });
  }

  QueryBuilder<SensorDataCollection, double?, QQueryOperations> ppgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ppg');
    });
  }

  QueryBuilder<SensorDataCollection, double?, QQueryOperations>
      timeStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeStamp');
    });
  }
}
