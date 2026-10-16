// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScanSessionsTable extends ScanSessions
    with TableInfo<$ScanSessionsTable, ScanSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cameraEmotionMeta = const VerificationMeta(
    'cameraEmotion',
  );
  @override
  late final GeneratedColumn<String> cameraEmotion = GeneratedColumn<String>(
    'camera_emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gsrUnitMeta = const VerificationMeta(
    'gsrUnit',
  );
  @override
  late final GeneratedColumn<String> gsrUnit = GeneratedColumn<String>(
    'gsr_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ppgUnitMeta = const VerificationMeta(
    'ppgUnit',
  );
  @override
  late final GeneratedColumn<String> ppgUnit = GeneratedColumn<String>(
    'ppg_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    emotion,
    cameraEmotion,
    gsrUnit,
    ppgUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    } else if (isInserting) {
      context.missing(_emotionMeta);
    }
    if (data.containsKey('camera_emotion')) {
      context.handle(
        _cameraEmotionMeta,
        cameraEmotion.isAcceptableOrUnknown(
          data['camera_emotion']!,
          _cameraEmotionMeta,
        ),
      );
    }
    if (data.containsKey('gsr_unit')) {
      context.handle(
        _gsrUnitMeta,
        gsrUnit.isAcceptableOrUnknown(data['gsr_unit']!, _gsrUnitMeta),
      );
    }
    if (data.containsKey('ppg_unit')) {
      context.handle(
        _ppgUnitMeta,
        ppgUnit.isAcceptableOrUnknown(data['ppg_unit']!, _ppgUnitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanSessionRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      startTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}start_time'],
          )!,
      emotion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}emotion'],
          )!,
      cameraEmotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camera_emotion'],
      ),
      gsrUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gsr_unit'],
      ),
      ppgUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ppg_unit'],
      ),
    );
  }

  @override
  $ScanSessionsTable createAlias(String alias) {
    return $ScanSessionsTable(attachedDatabase, alias);
  }
}

class ScanSessionRow extends DataClass implements Insertable<ScanSessionRow> {
  final int id;
  final DateTime startTime;
  final String emotion;
  final String? cameraEmotion;
  final String? gsrUnit;
  final String? ppgUnit;
  const ScanSessionRow({
    required this.id,
    required this.startTime,
    required this.emotion,
    this.cameraEmotion,
    this.gsrUnit,
    this.ppgUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    map['emotion'] = Variable<String>(emotion);
    if (!nullToAbsent || cameraEmotion != null) {
      map['camera_emotion'] = Variable<String>(cameraEmotion);
    }
    if (!nullToAbsent || gsrUnit != null) {
      map['gsr_unit'] = Variable<String>(gsrUnit);
    }
    if (!nullToAbsent || ppgUnit != null) {
      map['ppg_unit'] = Variable<String>(ppgUnit);
    }
    return map;
  }

  ScanSessionsCompanion toCompanion(bool nullToAbsent) {
    return ScanSessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      emotion: Value(emotion),
      cameraEmotion:
          cameraEmotion == null && nullToAbsent
              ? const Value.absent()
              : Value(cameraEmotion),
      gsrUnit:
          gsrUnit == null && nullToAbsent
              ? const Value.absent()
              : Value(gsrUnit),
      ppgUnit:
          ppgUnit == null && nullToAbsent
              ? const Value.absent()
              : Value(ppgUnit),
    );
  }

  factory ScanSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanSessionRow(
      id: serializer.fromJson<int>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      emotion: serializer.fromJson<String>(json['emotion']),
      cameraEmotion: serializer.fromJson<String?>(json['cameraEmotion']),
      gsrUnit: serializer.fromJson<String?>(json['gsrUnit']),
      ppgUnit: serializer.fromJson<String?>(json['ppgUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'emotion': serializer.toJson<String>(emotion),
      'cameraEmotion': serializer.toJson<String?>(cameraEmotion),
      'gsrUnit': serializer.toJson<String?>(gsrUnit),
      'ppgUnit': serializer.toJson<String?>(ppgUnit),
    };
  }

  ScanSessionRow copyWith({
    int? id,
    DateTime? startTime,
    String? emotion,
    Value<String?> cameraEmotion = const Value.absent(),
    Value<String?> gsrUnit = const Value.absent(),
    Value<String?> ppgUnit = const Value.absent(),
  }) => ScanSessionRow(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    emotion: emotion ?? this.emotion,
    cameraEmotion:
        cameraEmotion.present ? cameraEmotion.value : this.cameraEmotion,
    gsrUnit: gsrUnit.present ? gsrUnit.value : this.gsrUnit,
    ppgUnit: ppgUnit.present ? ppgUnit.value : this.ppgUnit,
  );
  ScanSessionRow copyWithCompanion(ScanSessionsCompanion data) {
    return ScanSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      cameraEmotion:
          data.cameraEmotion.present
              ? data.cameraEmotion.value
              : this.cameraEmotion,
      gsrUnit: data.gsrUnit.present ? data.gsrUnit.value : this.gsrUnit,
      ppgUnit: data.ppgUnit.present ? data.ppgUnit.value : this.ppgUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanSessionRow(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('emotion: $emotion, ')
          ..write('cameraEmotion: $cameraEmotion, ')
          ..write('gsrUnit: $gsrUnit, ')
          ..write('ppgUnit: $ppgUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startTime, emotion, cameraEmotion, gsrUnit, ppgUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanSessionRow &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.emotion == this.emotion &&
          other.cameraEmotion == this.cameraEmotion &&
          other.gsrUnit == this.gsrUnit &&
          other.ppgUnit == this.ppgUnit);
}

class ScanSessionsCompanion extends UpdateCompanion<ScanSessionRow> {
  final Value<int> id;
  final Value<DateTime> startTime;
  final Value<String> emotion;
  final Value<String?> cameraEmotion;
  final Value<String?> gsrUnit;
  final Value<String?> ppgUnit;
  const ScanSessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.emotion = const Value.absent(),
    this.cameraEmotion = const Value.absent(),
    this.gsrUnit = const Value.absent(),
    this.ppgUnit = const Value.absent(),
  });
  ScanSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startTime,
    required String emotion,
    this.cameraEmotion = const Value.absent(),
    this.gsrUnit = const Value.absent(),
    this.ppgUnit = const Value.absent(),
  }) : startTime = Value(startTime),
       emotion = Value(emotion);
  static Insertable<ScanSessionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? startTime,
    Expression<String>? emotion,
    Expression<String>? cameraEmotion,
    Expression<String>? gsrUnit,
    Expression<String>? ppgUnit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (emotion != null) 'emotion': emotion,
      if (cameraEmotion != null) 'camera_emotion': cameraEmotion,
      if (gsrUnit != null) 'gsr_unit': gsrUnit,
      if (ppgUnit != null) 'ppg_unit': ppgUnit,
    });
  }

  ScanSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startTime,
    Value<String>? emotion,
    Value<String?>? cameraEmotion,
    Value<String?>? gsrUnit,
    Value<String?>? ppgUnit,
  }) {
    return ScanSessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      emotion: emotion ?? this.emotion,
      cameraEmotion: cameraEmotion ?? this.cameraEmotion,
      gsrUnit: gsrUnit ?? this.gsrUnit,
      ppgUnit: ppgUnit ?? this.ppgUnit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (cameraEmotion.present) {
      map['camera_emotion'] = Variable<String>(cameraEmotion.value);
    }
    if (gsrUnit.present) {
      map['gsr_unit'] = Variable<String>(gsrUnit.value);
    }
    if (ppgUnit.present) {
      map['ppg_unit'] = Variable<String>(ppgUnit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('emotion: $emotion, ')
          ..write('cameraEmotion: $cameraEmotion, ')
          ..write('gsrUnit: $gsrUnit, ')
          ..write('ppgUnit: $ppgUnit')
          ..write(')'))
        .toString();
  }
}

class $SensorReadingsTable extends SensorReadings
    with TableInfo<$SensorReadingsTable, SensorReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scan_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timeStampMeta = const VerificationMeta(
    'timeStamp',
  );
  @override
  late final GeneratedColumn<double> timeStamp = GeneratedColumn<double>(
    'time_stamp',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelXMeta = const VerificationMeta('accelX');
  @override
  late final GeneratedColumn<double> accelX = GeneratedColumn<double>(
    'accel_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grsMeta = const VerificationMeta('grs');
  @override
  late final GeneratedColumn<double> grs = GeneratedColumn<double>(
    'grs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ppgMeta = const VerificationMeta('ppg');
  @override
  late final GeneratedColumn<double> ppg = GeneratedColumn<double>(
    'ppg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emgMeta = const VerificationMeta('emg');
  @override
  late final GeneratedColumn<double> emg = GeneratedColumn<double>(
    'emg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timeStamp,
    accelX,
    grs,
    ppg,
    emg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorReadingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('time_stamp')) {
      context.handle(
        _timeStampMeta,
        timeStamp.isAcceptableOrUnknown(data['time_stamp']!, _timeStampMeta),
      );
    }
    if (data.containsKey('accel_x')) {
      context.handle(
        _accelXMeta,
        accelX.isAcceptableOrUnknown(data['accel_x']!, _accelXMeta),
      );
    }
    if (data.containsKey('grs')) {
      context.handle(
        _grsMeta,
        grs.isAcceptableOrUnknown(data['grs']!, _grsMeta),
      );
    }
    if (data.containsKey('ppg')) {
      context.handle(
        _ppgMeta,
        ppg.isAcceptableOrUnknown(data['ppg']!, _ppgMeta),
      );
    }
    if (data.containsKey('emg')) {
      context.handle(
        _emgMeta,
        emg.isAcceptableOrUnknown(data['emg']!, _emgMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorReadingRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      sessionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}session_id'],
          )!,
      timeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}time_stamp'],
      ),
      accelX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_x'],
      ),
      grs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grs'],
      ),
      ppg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ppg'],
      ),
      emg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}emg'],
      ),
    );
  }

  @override
  $SensorReadingsTable createAlias(String alias) {
    return $SensorReadingsTable(attachedDatabase, alias);
  }
}

class SensorReadingRow extends DataClass
    implements Insertable<SensorReadingRow> {
  final int id;
  final int sessionId;
  final double? timeStamp;
  final double? accelX;
  final double? grs;
  final double? ppg;
  final double? emg;
  const SensorReadingRow({
    required this.id,
    required this.sessionId,
    this.timeStamp,
    this.accelX,
    this.grs,
    this.ppg,
    this.emg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || timeStamp != null) {
      map['time_stamp'] = Variable<double>(timeStamp);
    }
    if (!nullToAbsent || accelX != null) {
      map['accel_x'] = Variable<double>(accelX);
    }
    if (!nullToAbsent || grs != null) {
      map['grs'] = Variable<double>(grs);
    }
    if (!nullToAbsent || ppg != null) {
      map['ppg'] = Variable<double>(ppg);
    }
    if (!nullToAbsent || emg != null) {
      map['emg'] = Variable<double>(emg);
    }
    return map;
  }

  SensorReadingsCompanion toCompanion(bool nullToAbsent) {
    return SensorReadingsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timeStamp:
          timeStamp == null && nullToAbsent
              ? const Value.absent()
              : Value(timeStamp),
      accelX:
          accelX == null && nullToAbsent ? const Value.absent() : Value(accelX),
      grs: grs == null && nullToAbsent ? const Value.absent() : Value(grs),
      ppg: ppg == null && nullToAbsent ? const Value.absent() : Value(ppg),
      emg: emg == null && nullToAbsent ? const Value.absent() : Value(emg),
    );
  }

  factory SensorReadingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorReadingRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      timeStamp: serializer.fromJson<double?>(json['timeStamp']),
      accelX: serializer.fromJson<double?>(json['accelX']),
      grs: serializer.fromJson<double?>(json['grs']),
      ppg: serializer.fromJson<double?>(json['ppg']),
      emg: serializer.fromJson<double?>(json['emg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'timeStamp': serializer.toJson<double?>(timeStamp),
      'accelX': serializer.toJson<double?>(accelX),
      'grs': serializer.toJson<double?>(grs),
      'ppg': serializer.toJson<double?>(ppg),
      'emg': serializer.toJson<double?>(emg),
    };
  }

  SensorReadingRow copyWith({
    int? id,
    int? sessionId,
    Value<double?> timeStamp = const Value.absent(),
    Value<double?> accelX = const Value.absent(),
    Value<double?> grs = const Value.absent(),
    Value<double?> ppg = const Value.absent(),
    Value<double?> emg = const Value.absent(),
  }) => SensorReadingRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timeStamp: timeStamp.present ? timeStamp.value : this.timeStamp,
    accelX: accelX.present ? accelX.value : this.accelX,
    grs: grs.present ? grs.value : this.grs,
    ppg: ppg.present ? ppg.value : this.ppg,
    emg: emg.present ? emg.value : this.emg,
  );
  SensorReadingRow copyWithCompanion(SensorReadingsCompanion data) {
    return SensorReadingRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timeStamp: data.timeStamp.present ? data.timeStamp.value : this.timeStamp,
      accelX: data.accelX.present ? data.accelX.value : this.accelX,
      grs: data.grs.present ? data.grs.value : this.grs,
      ppg: data.ppg.present ? data.ppg.value : this.ppg,
      emg: data.emg.present ? data.emg.value : this.emg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('accelX: $accelX, ')
          ..write('grs: $grs, ')
          ..write('ppg: $ppg, ')
          ..write('emg: $emg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, timeStamp, accelX, grs, ppg, emg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorReadingRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timeStamp == this.timeStamp &&
          other.accelX == this.accelX &&
          other.grs == this.grs &&
          other.ppg == this.ppg &&
          other.emg == this.emg);
}

class SensorReadingsCompanion extends UpdateCompanion<SensorReadingRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<double?> timeStamp;
  final Value<double?> accelX;
  final Value<double?> grs;
  final Value<double?> ppg;
  final Value<double?> emg;
  const SensorReadingsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.accelX = const Value.absent(),
    this.grs = const Value.absent(),
    this.ppg = const Value.absent(),
    this.emg = const Value.absent(),
  });
  SensorReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.timeStamp = const Value.absent(),
    this.accelX = const Value.absent(),
    this.grs = const Value.absent(),
    this.ppg = const Value.absent(),
    this.emg = const Value.absent(),
  }) : sessionId = Value(sessionId);
  static Insertable<SensorReadingRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<double>? timeStamp,
    Expression<double>? accelX,
    Expression<double>? grs,
    Expression<double>? ppg,
    Expression<double>? emg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timeStamp != null) 'time_stamp': timeStamp,
      if (accelX != null) 'accel_x': accelX,
      if (grs != null) 'grs': grs,
      if (ppg != null) 'ppg': ppg,
      if (emg != null) 'emg': emg,
    });
  }

  SensorReadingsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<double?>? timeStamp,
    Value<double?>? accelX,
    Value<double?>? grs,
    Value<double?>? ppg,
    Value<double?>? emg,
  }) {
    return SensorReadingsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timeStamp: timeStamp ?? this.timeStamp,
      accelX: accelX ?? this.accelX,
      grs: grs ?? this.grs,
      ppg: ppg ?? this.ppg,
      emg: emg ?? this.emg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (timeStamp.present) {
      map['time_stamp'] = Variable<double>(timeStamp.value);
    }
    if (accelX.present) {
      map['accel_x'] = Variable<double>(accelX.value);
    }
    if (grs.present) {
      map['grs'] = Variable<double>(grs.value);
    }
    if (ppg.present) {
      map['ppg'] = Variable<double>(ppg.value);
    }
    if (emg.present) {
      map['emg'] = Variable<double>(emg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('accelX: $accelX, ')
          ..write('grs: $grs, ')
          ..write('ppg: $ppg, ')
          ..write('emg: $emg')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScanSessionsTable scanSessions = $ScanSessionsTable(this);
  late final $SensorReadingsTable sensorReadings = $SensorReadingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scanSessions,
    sensorReadings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scan_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sensor_readings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ScanSessionsTableCreateCompanionBuilder =
    ScanSessionsCompanion Function({
      Value<int> id,
      required DateTime startTime,
      required String emotion,
      Value<String?> cameraEmotion,
      Value<String?> gsrUnit,
      Value<String?> ppgUnit,
    });
typedef $$ScanSessionsTableUpdateCompanionBuilder =
    ScanSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startTime,
      Value<String> emotion,
      Value<String?> cameraEmotion,
      Value<String?> gsrUnit,
      Value<String?> ppgUnit,
    });

final class $$ScanSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ScanSessionsTable, ScanSessionRow> {
  $$ScanSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SensorReadingsTable, List<SensorReadingRow>>
  _sensorReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sensorReadings,
    aliasName: $_aliasNameGenerator(
      db.scanSessions.id,
      db.sensorReadings.sessionId,
    ),
  );

  $$SensorReadingsTableProcessedTableManager get sensorReadingsRefs {
    final manager = $$SensorReadingsTableTableManager(
      $_db,
      $_db.sensorReadings,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sensorReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScanSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanSessionsTable> {
  $$ScanSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cameraEmotion => $composableBuilder(
    column: $table.cameraEmotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gsrUnit => $composableBuilder(
    column: $table.gsrUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ppgUnit => $composableBuilder(
    column: $table.ppgUnit,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sensorReadingsRefs(
    Expression<bool> Function($$SensorReadingsTableFilterComposer f) f,
  ) {
    final $$SensorReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableFilterComposer(
            $db: $db,
            $table: $db.sensorReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScanSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanSessionsTable> {
  $$ScanSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cameraEmotion => $composableBuilder(
    column: $table.cameraEmotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gsrUnit => $composableBuilder(
    column: $table.gsrUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ppgUnit => $composableBuilder(
    column: $table.ppgUnit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanSessionsTable> {
  $$ScanSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get cameraEmotion => $composableBuilder(
    column: $table.cameraEmotion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gsrUnit =>
      $composableBuilder(column: $table.gsrUnit, builder: (column) => column);

  GeneratedColumn<String> get ppgUnit =>
      $composableBuilder(column: $table.ppgUnit, builder: (column) => column);

  Expression<T> sensorReadingsRefs<T extends Object>(
    Expression<T> Function($$SensorReadingsTableAnnotationComposer a) f,
  ) {
    final $$SensorReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.sensorReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScanSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanSessionsTable,
          ScanSessionRow,
          $$ScanSessionsTableFilterComposer,
          $$ScanSessionsTableOrderingComposer,
          $$ScanSessionsTableAnnotationComposer,
          $$ScanSessionsTableCreateCompanionBuilder,
          $$ScanSessionsTableUpdateCompanionBuilder,
          (ScanSessionRow, $$ScanSessionsTableReferences),
          ScanSessionRow,
          PrefetchHooks Function({bool sensorReadingsRefs})
        > {
  $$ScanSessionsTableTableManager(_$AppDatabase db, $ScanSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ScanSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ScanSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ScanSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<String> emotion = const Value.absent(),
                Value<String?> cameraEmotion = const Value.absent(),
                Value<String?> gsrUnit = const Value.absent(),
                Value<String?> ppgUnit = const Value.absent(),
              }) => ScanSessionsCompanion(
                id: id,
                startTime: startTime,
                emotion: emotion,
                cameraEmotion: cameraEmotion,
                gsrUnit: gsrUnit,
                ppgUnit: ppgUnit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startTime,
                required String emotion,
                Value<String?> cameraEmotion = const Value.absent(),
                Value<String?> gsrUnit = const Value.absent(),
                Value<String?> ppgUnit = const Value.absent(),
              }) => ScanSessionsCompanion.insert(
                id: id,
                startTime: startTime,
                emotion: emotion,
                cameraEmotion: cameraEmotion,
                gsrUnit: gsrUnit,
                ppgUnit: ppgUnit,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ScanSessionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({sensorReadingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sensorReadingsRefs) db.sensorReadings,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sensorReadingsRefs)
                    await $_getPrefetchedData<
                      ScanSessionRow,
                      $ScanSessionsTable,
                      SensorReadingRow
                    >(
                      currentTable: table,
                      referencedTable: $$ScanSessionsTableReferences
                          ._sensorReadingsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ScanSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sensorReadingsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScanSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanSessionsTable,
      ScanSessionRow,
      $$ScanSessionsTableFilterComposer,
      $$ScanSessionsTableOrderingComposer,
      $$ScanSessionsTableAnnotationComposer,
      $$ScanSessionsTableCreateCompanionBuilder,
      $$ScanSessionsTableUpdateCompanionBuilder,
      (ScanSessionRow, $$ScanSessionsTableReferences),
      ScanSessionRow,
      PrefetchHooks Function({bool sensorReadingsRefs})
    >;
typedef $$SensorReadingsTableCreateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<double?> timeStamp,
      Value<double?> accelX,
      Value<double?> grs,
      Value<double?> ppg,
      Value<double?> emg,
    });
typedef $$SensorReadingsTableUpdateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<double?> timeStamp,
      Value<double?> accelX,
      Value<double?> grs,
      Value<double?> ppg,
      Value<double?> emg,
    });

final class $$SensorReadingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SensorReadingsTable, SensorReadingRow> {
  $$SensorReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScanSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.scanSessions.createAlias(
        $_aliasNameGenerator(db.sensorReadings.sessionId, db.scanSessions.id),
      );

  $$ScanSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ScanSessionsTableTableManager(
      $_db,
      $_db.scanSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SensorReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timeStamp => $composableBuilder(
    column: $table.timeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelX => $composableBuilder(
    column: $table.accelX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grs => $composableBuilder(
    column: $table.grs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ppg => $composableBuilder(
    column: $table.ppg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get emg => $composableBuilder(
    column: $table.emg,
    builder: (column) => ColumnFilters(column),
  );

  $$ScanSessionsTableFilterComposer get sessionId {
    final $$ScanSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.scanSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanSessionsTableFilterComposer(
            $db: $db,
            $table: $db.scanSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timeStamp => $composableBuilder(
    column: $table.timeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelX => $composableBuilder(
    column: $table.accelX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grs => $composableBuilder(
    column: $table.grs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ppg => $composableBuilder(
    column: $table.ppg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get emg => $composableBuilder(
    column: $table.emg,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScanSessionsTableOrderingComposer get sessionId {
    final $$ScanSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.scanSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.scanSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get timeStamp =>
      $composableBuilder(column: $table.timeStamp, builder: (column) => column);

  GeneratedColumn<double> get accelX =>
      $composableBuilder(column: $table.accelX, builder: (column) => column);

  GeneratedColumn<double> get grs =>
      $composableBuilder(column: $table.grs, builder: (column) => column);

  GeneratedColumn<double> get ppg =>
      $composableBuilder(column: $table.ppg, builder: (column) => column);

  GeneratedColumn<double> get emg =>
      $composableBuilder(column: $table.emg, builder: (column) => column);

  $$ScanSessionsTableAnnotationComposer get sessionId {
    final $$ScanSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.scanSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.scanSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorReadingsTable,
          SensorReadingRow,
          $$SensorReadingsTableFilterComposer,
          $$SensorReadingsTableOrderingComposer,
          $$SensorReadingsTableAnnotationComposer,
          $$SensorReadingsTableCreateCompanionBuilder,
          $$SensorReadingsTableUpdateCompanionBuilder,
          (SensorReadingRow, $$SensorReadingsTableReferences),
          SensorReadingRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SensorReadingsTableTableManager(
    _$AppDatabase db,
    $SensorReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SensorReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SensorReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SensorReadingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<double?> timeStamp = const Value.absent(),
                Value<double?> accelX = const Value.absent(),
                Value<double?> grs = const Value.absent(),
                Value<double?> ppg = const Value.absent(),
                Value<double?> emg = const Value.absent(),
              }) => SensorReadingsCompanion(
                id: id,
                sessionId: sessionId,
                timeStamp: timeStamp,
                accelX: accelX,
                grs: grs,
                ppg: ppg,
                emg: emg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<double?> timeStamp = const Value.absent(),
                Value<double?> accelX = const Value.absent(),
                Value<double?> grs = const Value.absent(),
                Value<double?> ppg = const Value.absent(),
                Value<double?> emg = const Value.absent(),
              }) => SensorReadingsCompanion.insert(
                id: id,
                sessionId: sessionId,
                timeStamp: timeStamp,
                accelX: accelX,
                grs: grs,
                ppg: ppg,
                emg: emg,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SensorReadingsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (sessionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$SensorReadingsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn:
                                $$SensorReadingsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SensorReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorReadingsTable,
      SensorReadingRow,
      $$SensorReadingsTableFilterComposer,
      $$SensorReadingsTableOrderingComposer,
      $$SensorReadingsTableAnnotationComposer,
      $$SensorReadingsTableCreateCompanionBuilder,
      $$SensorReadingsTableUpdateCompanionBuilder,
      (SensorReadingRow, $$SensorReadingsTableReferences),
      SensorReadingRow,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanSessionsTableTableManager get scanSessions =>
      $$ScanSessionsTableTableManager(_db, _db.scanSessions);
  $$SensorReadingsTableTableManager get sensorReadings =>
      $$SensorReadingsTableTableManager(_db, _db.sensorReadings);
}
