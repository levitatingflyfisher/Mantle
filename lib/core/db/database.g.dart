// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, label, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<MemberRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String label;
  final int color;
  final DateTime createdAt;
  const MemberRow(
      {required this.id,
      required this.label,
      required this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      label: Value(label),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory MemberRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemberRow copyWith(
          {String? id, String? label, int? color, DateTime? createdAt}) =>
      MemberRow(
        id: id ?? this.id,
        label: label ?? this.label,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );
  MemberRow copyWithCompanion(MembersCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class MembersCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> color;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String label,
    required int color,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        label = Value(label),
        color = Value(color),
        createdAt = Value(createdAt);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? label,
      Value<int>? color,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MembersCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundsTable extends Rounds with TableInfo<$RoundsTable, Round> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckVersionMeta =
      const VerificationMeta('deckVersion');
  @override
  late final GeneratedColumn<int> deckVersion = GeneratedColumn<int>(
      'deck_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, deckVersion, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rounds';
  @override
  VerificationContext validateIntegrity(Insertable<Round> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_version')) {
      context.handle(
          _deckVersionMeta,
          deckVersion.isAcceptableOrUnknown(
              data['deck_version']!, _deckVersionMeta));
    } else if (isInserting) {
      context.missing(_deckVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Round map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Round(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deck_version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RoundsTable createAlias(String alias) {
    return $RoundsTable(attachedDatabase, alias);
  }
}

class Round extends DataClass implements Insertable<Round> {
  final String id;
  final int deckVersion;
  final DateTime createdAt;
  const Round(
      {required this.id, required this.deckVersion, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_version'] = Variable<int>(deckVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      deckVersion: Value(deckVersion),
      createdAt: Value(createdAt),
    );
  }

  factory Round.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Round(
      id: serializer.fromJson<String>(json['id']),
      deckVersion: serializer.fromJson<int>(json['deckVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckVersion': serializer.toJson<int>(deckVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Round copyWith({String? id, int? deckVersion, DateTime? createdAt}) => Round(
        id: id ?? this.id,
        deckVersion: deckVersion ?? this.deckVersion,
        createdAt: createdAt ?? this.createdAt,
      );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      deckVersion:
          data.deckVersion.present ? data.deckVersion.value : this.deckVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('deckVersion: $deckVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deckVersion, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.deckVersion == this.deckVersion &&
          other.createdAt == this.createdAt);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<String> id;
  final Value<int> deckVersion;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.deckVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundsCompanion.insert({
    required String id,
    required int deckVersion,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckVersion = Value(deckVersion),
        createdAt = Value(createdAt);
  static Insertable<Round> custom({
    Expression<String>? id,
    Expression<int>? deckVersion,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckVersion != null) 'deck_version': deckVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundsCompanion copyWith(
      {Value<String>? id,
      Value<int>? deckVersion,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RoundsCompanion(
      id: id ?? this.id,
      deckVersion: deckVersion ?? this.deckVersion,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckVersion.present) {
      map['deck_version'] = Variable<int>(deckVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('deckVersion: $deckVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RankingSessionsTable extends RankingSessions
    with TableInfo<$RankingSessionsTable, RankingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RankingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roundIdMeta =
      const VerificationMeta('roundId');
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
      'round_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompleteMeta =
      const VerificationMeta('isComplete');
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
      'is_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _resultsLockedMeta =
      const VerificationMeta('resultsLocked');
  @override
  late final GeneratedColumn<bool> resultsLocked = GeneratedColumn<bool>(
      'results_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("results_locked" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, roundId, memberId, domain, isComplete, resultsLocked, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranking_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<RankingSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('round_id')) {
      context.handle(_roundIdMeta,
          roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta));
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
          _isCompleteMeta,
          isComplete.isAcceptableOrUnknown(
              data['is_complete']!, _isCompleteMeta));
    }
    if (data.containsKey('results_locked')) {
      context.handle(
          _resultsLockedMeta,
          resultsLocked.isAcceptableOrUnknown(
              data['results_locked']!, _resultsLockedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RankingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RankingSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      roundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}round_id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      isComplete: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_complete'])!,
      resultsLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}results_locked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RankingSessionsTable createAlias(String alias) {
    return $RankingSessionsTable(attachedDatabase, alias);
  }
}

class RankingSession extends DataClass implements Insertable<RankingSession> {
  final String id;
  final String roundId;
  final String memberId;
  final String domain;
  final bool isComplete;
  final bool resultsLocked;
  final DateTime createdAt;
  const RankingSession(
      {required this.id,
      required this.roundId,
      required this.memberId,
      required this.domain,
      required this.isComplete,
      required this.resultsLocked,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['round_id'] = Variable<String>(roundId);
    map['member_id'] = Variable<String>(memberId);
    map['domain'] = Variable<String>(domain);
    map['is_complete'] = Variable<bool>(isComplete);
    map['results_locked'] = Variable<bool>(resultsLocked);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RankingSessionsCompanion toCompanion(bool nullToAbsent) {
    return RankingSessionsCompanion(
      id: Value(id),
      roundId: Value(roundId),
      memberId: Value(memberId),
      domain: Value(domain),
      isComplete: Value(isComplete),
      resultsLocked: Value(resultsLocked),
      createdAt: Value(createdAt),
    );
  }

  factory RankingSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RankingSession(
      id: serializer.fromJson<String>(json['id']),
      roundId: serializer.fromJson<String>(json['roundId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      domain: serializer.fromJson<String>(json['domain']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      resultsLocked: serializer.fromJson<bool>(json['resultsLocked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roundId': serializer.toJson<String>(roundId),
      'memberId': serializer.toJson<String>(memberId),
      'domain': serializer.toJson<String>(domain),
      'isComplete': serializer.toJson<bool>(isComplete),
      'resultsLocked': serializer.toJson<bool>(resultsLocked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RankingSession copyWith(
          {String? id,
          String? roundId,
          String? memberId,
          String? domain,
          bool? isComplete,
          bool? resultsLocked,
          DateTime? createdAt}) =>
      RankingSession(
        id: id ?? this.id,
        roundId: roundId ?? this.roundId,
        memberId: memberId ?? this.memberId,
        domain: domain ?? this.domain,
        isComplete: isComplete ?? this.isComplete,
        resultsLocked: resultsLocked ?? this.resultsLocked,
        createdAt: createdAt ?? this.createdAt,
      );
  RankingSession copyWithCompanion(RankingSessionsCompanion data) {
    return RankingSession(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      domain: data.domain.present ? data.domain.value : this.domain,
      isComplete:
          data.isComplete.present ? data.isComplete.value : this.isComplete,
      resultsLocked: data.resultsLocked.present
          ? data.resultsLocked.value
          : this.resultsLocked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RankingSession(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('memberId: $memberId, ')
          ..write('domain: $domain, ')
          ..write('isComplete: $isComplete, ')
          ..write('resultsLocked: $resultsLocked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, roundId, memberId, domain, isComplete, resultsLocked, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RankingSession &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.memberId == this.memberId &&
          other.domain == this.domain &&
          other.isComplete == this.isComplete &&
          other.resultsLocked == this.resultsLocked &&
          other.createdAt == this.createdAt);
}

class RankingSessionsCompanion extends UpdateCompanion<RankingSession> {
  final Value<String> id;
  final Value<String> roundId;
  final Value<String> memberId;
  final Value<String> domain;
  final Value<bool> isComplete;
  final Value<bool> resultsLocked;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RankingSessionsCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.domain = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.resultsLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RankingSessionsCompanion.insert({
    required String id,
    required String roundId,
    required String memberId,
    required String domain,
    this.isComplete = const Value.absent(),
    this.resultsLocked = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        roundId = Value(roundId),
        memberId = Value(memberId),
        domain = Value(domain),
        createdAt = Value(createdAt);
  static Insertable<RankingSession> custom({
    Expression<String>? id,
    Expression<String>? roundId,
    Expression<String>? memberId,
    Expression<String>? domain,
    Expression<bool>? isComplete,
    Expression<bool>? resultsLocked,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (memberId != null) 'member_id': memberId,
      if (domain != null) 'domain': domain,
      if (isComplete != null) 'is_complete': isComplete,
      if (resultsLocked != null) 'results_locked': resultsLocked,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RankingSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? roundId,
      Value<String>? memberId,
      Value<String>? domain,
      Value<bool>? isComplete,
      Value<bool>? resultsLocked,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RankingSessionsCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      memberId: memberId ?? this.memberId,
      domain: domain ?? this.domain,
      isComplete: isComplete ?? this.isComplete,
      resultsLocked: resultsLocked ?? this.resultsLocked,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (resultsLocked.present) {
      map['results_locked'] = Variable<bool>(resultsLocked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RankingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('memberId: $memberId, ')
          ..write('domain: $domain, ')
          ..write('isComplete: $isComplete, ')
          ..write('resultsLocked: $resultsLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RankingMatchesTable extends RankingMatches
    with TableInfo<$RankingMatchesTable, RankingMatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RankingMatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idAMeta = const VerificationMeta('idA');
  @override
  late final GeneratedColumn<String> idA = GeneratedColumn<String>(
      'id_a', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idBMeta = const VerificationMeta('idB');
  @override
  late final GeneratedColumn<String> idB = GeneratedColumn<String>(
      'id_b', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _decidedAtMeta =
      const VerificationMeta('decidedAt');
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
      'decided_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, idA, idB, outcome, decidedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranking_matches';
  @override
  VerificationContext validateIntegrity(Insertable<RankingMatch> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('id_a')) {
      context.handle(
          _idAMeta, idA.isAcceptableOrUnknown(data['id_a']!, _idAMeta));
    } else if (isInserting) {
      context.missing(_idAMeta);
    }
    if (data.containsKey('id_b')) {
      context.handle(
          _idBMeta, idB.isAcceptableOrUnknown(data['id_b']!, _idBMeta));
    } else if (isInserting) {
      context.missing(_idBMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('decided_at')) {
      context.handle(_decidedAtMeta,
          decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta));
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RankingMatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RankingMatch(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      idA: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_a'])!,
      idB: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_b'])!,
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome'])!,
      decidedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}decided_at'])!,
    );
  }

  @override
  $RankingMatchesTable createAlias(String alias) {
    return $RankingMatchesTable(attachedDatabase, alias);
  }
}

class RankingMatch extends DataClass implements Insertable<RankingMatch> {
  final String id;
  final String sessionId;
  final String idA;
  final String idB;
  final String outcome;
  final DateTime decidedAt;
  const RankingMatch(
      {required this.id,
      required this.sessionId,
      required this.idA,
      required this.idB,
      required this.outcome,
      required this.decidedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['id_a'] = Variable<String>(idA);
    map['id_b'] = Variable<String>(idB);
    map['outcome'] = Variable<String>(outcome);
    map['decided_at'] = Variable<DateTime>(decidedAt);
    return map;
  }

  RankingMatchesCompanion toCompanion(bool nullToAbsent) {
    return RankingMatchesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      idA: Value(idA),
      idB: Value(idB),
      outcome: Value(outcome),
      decidedAt: Value(decidedAt),
    );
  }

  factory RankingMatch.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RankingMatch(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      idA: serializer.fromJson<String>(json['idA']),
      idB: serializer.fromJson<String>(json['idB']),
      outcome: serializer.fromJson<String>(json['outcome']),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'idA': serializer.toJson<String>(idA),
      'idB': serializer.toJson<String>(idB),
      'outcome': serializer.toJson<String>(outcome),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
    };
  }

  RankingMatch copyWith(
          {String? id,
          String? sessionId,
          String? idA,
          String? idB,
          String? outcome,
          DateTime? decidedAt}) =>
      RankingMatch(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        idA: idA ?? this.idA,
        idB: idB ?? this.idB,
        outcome: outcome ?? this.outcome,
        decidedAt: decidedAt ?? this.decidedAt,
      );
  RankingMatch copyWithCompanion(RankingMatchesCompanion data) {
    return RankingMatch(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      idA: data.idA.present ? data.idA.value : this.idA,
      idB: data.idB.present ? data.idB.value : this.idB,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RankingMatch(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('idA: $idA, ')
          ..write('idB: $idB, ')
          ..write('outcome: $outcome, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, idA, idB, outcome, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RankingMatch &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.idA == this.idA &&
          other.idB == this.idB &&
          other.outcome == this.outcome &&
          other.decidedAt == this.decidedAt);
}

class RankingMatchesCompanion extends UpdateCompanion<RankingMatch> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> idA;
  final Value<String> idB;
  final Value<String> outcome;
  final Value<DateTime> decidedAt;
  final Value<int> rowid;
  const RankingMatchesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.idA = const Value.absent(),
    this.idB = const Value.absent(),
    this.outcome = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RankingMatchesCompanion.insert({
    required String id,
    required String sessionId,
    required String idA,
    required String idB,
    required String outcome,
    required DateTime decidedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        idA = Value(idA),
        idB = Value(idB),
        outcome = Value(outcome),
        decidedAt = Value(decidedAt);
  static Insertable<RankingMatch> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? idA,
    Expression<String>? idB,
    Expression<String>? outcome,
    Expression<DateTime>? decidedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (idA != null) 'id_a': idA,
      if (idB != null) 'id_b': idB,
      if (outcome != null) 'outcome': outcome,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RankingMatchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? idA,
      Value<String>? idB,
      Value<String>? outcome,
      Value<DateTime>? decidedAt,
      Value<int>? rowid}) {
    return RankingMatchesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      idA: idA ?? this.idA,
      idB: idB ?? this.idB,
      outcome: outcome ?? this.outcome,
      decidedAt: decidedAt ?? this.decidedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (idA.present) {
      map['id_a'] = Variable<String>(idA.value);
    }
    if (idB.present) {
      map['id_b'] = Variable<String>(idB.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RankingMatchesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('idA: $idA, ')
          ..write('idB: $idB, ')
          ..write('outcome: $outcome, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChartersTable extends Charters with TableInfo<$ChartersTable, Charter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChartersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roundIdMeta =
      const VerificationMeta('roundId');
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
      'round_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseNameMeta =
      const VerificationMeta('houseName');
  @override
  late final GeneratedColumn<String> houseName = GeneratedColumn<String>(
      'house_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _mottoMeta = const VerificationMeta('motto');
  @override
  late final GeneratedColumn<String> motto = GeneratedColumn<String>(
      'motto', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _spineItemIdsMeta =
      const VerificationMeta('spineItemIds');
  @override
  late final GeneratedColumn<String> spineItemIds = GeneratedColumn<String>(
      'spine_item_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _throughlinesMeta =
      const VerificationMeta('throughlines');
  @override
  late final GeneratedColumn<String> throughlines = GeneratedColumn<String>(
      'throughlines', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contestedItemIdsMeta =
      const VerificationMeta('contestedItemIds');
  @override
  late final GeneratedColumn<String> contestedItemIds = GeneratedColumn<String>(
      'contested_item_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyOverridesMeta =
      const VerificationMeta('bodyOverrides');
  @override
  late final GeneratedColumn<String> bodyOverrides = GeneratedColumn<String>(
      'body_overrides', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roundId,
        houseName,
        motto,
        createdAt,
        spineItemIds,
        throughlines,
        contestedItemIds,
        bodyOverrides
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'charters';
  @override
  VerificationContext validateIntegrity(Insertable<Charter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('round_id')) {
      context.handle(_roundIdMeta,
          roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta));
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('house_name')) {
      context.handle(_houseNameMeta,
          houseName.isAcceptableOrUnknown(data['house_name']!, _houseNameMeta));
    }
    if (data.containsKey('motto')) {
      context.handle(
          _mottoMeta, motto.isAcceptableOrUnknown(data['motto']!, _mottoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('spine_item_ids')) {
      context.handle(
          _spineItemIdsMeta,
          spineItemIds.isAcceptableOrUnknown(
              data['spine_item_ids']!, _spineItemIdsMeta));
    } else if (isInserting) {
      context.missing(_spineItemIdsMeta);
    }
    if (data.containsKey('throughlines')) {
      context.handle(
          _throughlinesMeta,
          throughlines.isAcceptableOrUnknown(
              data['throughlines']!, _throughlinesMeta));
    } else if (isInserting) {
      context.missing(_throughlinesMeta);
    }
    if (data.containsKey('contested_item_ids')) {
      context.handle(
          _contestedItemIdsMeta,
          contestedItemIds.isAcceptableOrUnknown(
              data['contested_item_ids']!, _contestedItemIdsMeta));
    } else if (isInserting) {
      context.missing(_contestedItemIdsMeta);
    }
    if (data.containsKey('body_overrides')) {
      context.handle(
          _bodyOverridesMeta,
          bodyOverrides.isAcceptableOrUnknown(
              data['body_overrides']!, _bodyOverridesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Charter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Charter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      roundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}round_id'])!,
      houseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_name'])!,
      motto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motto'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      spineItemIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}spine_item_ids'])!,
      throughlines: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}throughlines'])!,
      contestedItemIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contested_item_ids'])!,
      bodyOverrides: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_overrides'])!,
    );
  }

  @override
  $ChartersTable createAlias(String alias) {
    return $ChartersTable(attachedDatabase, alias);
  }
}

class Charter extends DataClass implements Insertable<Charter> {
  final String id;
  final String roundId;
  final String houseName;
  final String motto;
  final DateTime createdAt;
  final String spineItemIds;
  final String throughlines;
  final String contestedItemIds;
  final String bodyOverrides;
  const Charter(
      {required this.id,
      required this.roundId,
      required this.houseName,
      required this.motto,
      required this.createdAt,
      required this.spineItemIds,
      required this.throughlines,
      required this.contestedItemIds,
      required this.bodyOverrides});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['round_id'] = Variable<String>(roundId);
    map['house_name'] = Variable<String>(houseName);
    map['motto'] = Variable<String>(motto);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['spine_item_ids'] = Variable<String>(spineItemIds);
    map['throughlines'] = Variable<String>(throughlines);
    map['contested_item_ids'] = Variable<String>(contestedItemIds);
    map['body_overrides'] = Variable<String>(bodyOverrides);
    return map;
  }

  ChartersCompanion toCompanion(bool nullToAbsent) {
    return ChartersCompanion(
      id: Value(id),
      roundId: Value(roundId),
      houseName: Value(houseName),
      motto: Value(motto),
      createdAt: Value(createdAt),
      spineItemIds: Value(spineItemIds),
      throughlines: Value(throughlines),
      contestedItemIds: Value(contestedItemIds),
      bodyOverrides: Value(bodyOverrides),
    );
  }

  factory Charter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Charter(
      id: serializer.fromJson<String>(json['id']),
      roundId: serializer.fromJson<String>(json['roundId']),
      houseName: serializer.fromJson<String>(json['houseName']),
      motto: serializer.fromJson<String>(json['motto']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      spineItemIds: serializer.fromJson<String>(json['spineItemIds']),
      throughlines: serializer.fromJson<String>(json['throughlines']),
      contestedItemIds: serializer.fromJson<String>(json['contestedItemIds']),
      bodyOverrides: serializer.fromJson<String>(json['bodyOverrides']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roundId': serializer.toJson<String>(roundId),
      'houseName': serializer.toJson<String>(houseName),
      'motto': serializer.toJson<String>(motto),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'spineItemIds': serializer.toJson<String>(spineItemIds),
      'throughlines': serializer.toJson<String>(throughlines),
      'contestedItemIds': serializer.toJson<String>(contestedItemIds),
      'bodyOverrides': serializer.toJson<String>(bodyOverrides),
    };
  }

  Charter copyWith(
          {String? id,
          String? roundId,
          String? houseName,
          String? motto,
          DateTime? createdAt,
          String? spineItemIds,
          String? throughlines,
          String? contestedItemIds,
          String? bodyOverrides}) =>
      Charter(
        id: id ?? this.id,
        roundId: roundId ?? this.roundId,
        houseName: houseName ?? this.houseName,
        motto: motto ?? this.motto,
        createdAt: createdAt ?? this.createdAt,
        spineItemIds: spineItemIds ?? this.spineItemIds,
        throughlines: throughlines ?? this.throughlines,
        contestedItemIds: contestedItemIds ?? this.contestedItemIds,
        bodyOverrides: bodyOverrides ?? this.bodyOverrides,
      );
  Charter copyWithCompanion(ChartersCompanion data) {
    return Charter(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      houseName: data.houseName.present ? data.houseName.value : this.houseName,
      motto: data.motto.present ? data.motto.value : this.motto,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      spineItemIds: data.spineItemIds.present
          ? data.spineItemIds.value
          : this.spineItemIds,
      throughlines: data.throughlines.present
          ? data.throughlines.value
          : this.throughlines,
      contestedItemIds: data.contestedItemIds.present
          ? data.contestedItemIds.value
          : this.contestedItemIds,
      bodyOverrides: data.bodyOverrides.present
          ? data.bodyOverrides.value
          : this.bodyOverrides,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Charter(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('houseName: $houseName, ')
          ..write('motto: $motto, ')
          ..write('createdAt: $createdAt, ')
          ..write('spineItemIds: $spineItemIds, ')
          ..write('throughlines: $throughlines, ')
          ..write('contestedItemIds: $contestedItemIds, ')
          ..write('bodyOverrides: $bodyOverrides')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roundId, houseName, motto, createdAt,
      spineItemIds, throughlines, contestedItemIds, bodyOverrides);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Charter &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.houseName == this.houseName &&
          other.motto == this.motto &&
          other.createdAt == this.createdAt &&
          other.spineItemIds == this.spineItemIds &&
          other.throughlines == this.throughlines &&
          other.contestedItemIds == this.contestedItemIds &&
          other.bodyOverrides == this.bodyOverrides);
}

class ChartersCompanion extends UpdateCompanion<Charter> {
  final Value<String> id;
  final Value<String> roundId;
  final Value<String> houseName;
  final Value<String> motto;
  final Value<DateTime> createdAt;
  final Value<String> spineItemIds;
  final Value<String> throughlines;
  final Value<String> contestedItemIds;
  final Value<String> bodyOverrides;
  final Value<int> rowid;
  const ChartersCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.houseName = const Value.absent(),
    this.motto = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.spineItemIds = const Value.absent(),
    this.throughlines = const Value.absent(),
    this.contestedItemIds = const Value.absent(),
    this.bodyOverrides = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChartersCompanion.insert({
    required String id,
    required String roundId,
    this.houseName = const Value.absent(),
    this.motto = const Value.absent(),
    required DateTime createdAt,
    required String spineItemIds,
    required String throughlines,
    required String contestedItemIds,
    this.bodyOverrides = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        roundId = Value(roundId),
        createdAt = Value(createdAt),
        spineItemIds = Value(spineItemIds),
        throughlines = Value(throughlines),
        contestedItemIds = Value(contestedItemIds);
  static Insertable<Charter> custom({
    Expression<String>? id,
    Expression<String>? roundId,
    Expression<String>? houseName,
    Expression<String>? motto,
    Expression<DateTime>? createdAt,
    Expression<String>? spineItemIds,
    Expression<String>? throughlines,
    Expression<String>? contestedItemIds,
    Expression<String>? bodyOverrides,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (houseName != null) 'house_name': houseName,
      if (motto != null) 'motto': motto,
      if (createdAt != null) 'created_at': createdAt,
      if (spineItemIds != null) 'spine_item_ids': spineItemIds,
      if (throughlines != null) 'throughlines': throughlines,
      if (contestedItemIds != null) 'contested_item_ids': contestedItemIds,
      if (bodyOverrides != null) 'body_overrides': bodyOverrides,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChartersCompanion copyWith(
      {Value<String>? id,
      Value<String>? roundId,
      Value<String>? houseName,
      Value<String>? motto,
      Value<DateTime>? createdAt,
      Value<String>? spineItemIds,
      Value<String>? throughlines,
      Value<String>? contestedItemIds,
      Value<String>? bodyOverrides,
      Value<int>? rowid}) {
    return ChartersCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      houseName: houseName ?? this.houseName,
      motto: motto ?? this.motto,
      createdAt: createdAt ?? this.createdAt,
      spineItemIds: spineItemIds ?? this.spineItemIds,
      throughlines: throughlines ?? this.throughlines,
      contestedItemIds: contestedItemIds ?? this.contestedItemIds,
      bodyOverrides: bodyOverrides ?? this.bodyOverrides,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (houseName.present) {
      map['house_name'] = Variable<String>(houseName.value);
    }
    if (motto.present) {
      map['motto'] = Variable<String>(motto.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (spineItemIds.present) {
      map['spine_item_ids'] = Variable<String>(spineItemIds.value);
    }
    if (throughlines.present) {
      map['throughlines'] = Variable<String>(throughlines.value);
    }
    if (contestedItemIds.present) {
      map['contested_item_ids'] = Variable<String>(contestedItemIds.value);
    }
    if (bodyOverrides.present) {
      map['body_overrides'] = Variable<String>(bodyOverrides.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChartersCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('houseName: $houseName, ')
          ..write('motto: $motto, ')
          ..write('createdAt: $createdAt, ')
          ..write('spineItemIds: $spineItemIds, ')
          ..write('throughlines: $throughlines, ')
          ..write('contestedItemIds: $contestedItemIds, ')
          ..write('bodyOverrides: $bodyOverrides, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpotProgressTable extends SpotProgress
    with TableInfo<$SpotProgressTable, SpotProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpotProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seenCountMeta =
      const VerificationMeta('seenCount');
  @override
  late final GeneratedColumn<int> seenCount = GeneratedColumn<int>(
      'seen_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _correctCountMeta =
      const VerificationMeta('correctCount');
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
      'correct_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [memberId, questionId, seenCount, correctCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spot_progress';
  @override
  VerificationContext validateIntegrity(Insertable<SpotProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('seen_count')) {
      context.handle(_seenCountMeta,
          seenCount.isAcceptableOrUnknown(data['seen_count']!, _seenCountMeta));
    }
    if (data.containsKey('correct_count')) {
      context.handle(
          _correctCountMeta,
          correctCount.isAcceptableOrUnknown(
              data['correct_count']!, _correctCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberId, questionId};
  @override
  SpotProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpotProgressData(
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      seenCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seen_count'])!,
      correctCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_count'])!,
    );
  }

  @override
  $SpotProgressTable createAlias(String alias) {
    return $SpotProgressTable(attachedDatabase, alias);
  }
}

class SpotProgressData extends DataClass
    implements Insertable<SpotProgressData> {
  final String memberId;
  final String questionId;
  final int seenCount;
  final int correctCount;
  const SpotProgressData(
      {required this.memberId,
      required this.questionId,
      required this.seenCount,
      required this.correctCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['member_id'] = Variable<String>(memberId);
    map['question_id'] = Variable<String>(questionId);
    map['seen_count'] = Variable<int>(seenCount);
    map['correct_count'] = Variable<int>(correctCount);
    return map;
  }

  SpotProgressCompanion toCompanion(bool nullToAbsent) {
    return SpotProgressCompanion(
      memberId: Value(memberId),
      questionId: Value(questionId),
      seenCount: Value(seenCount),
      correctCount: Value(correctCount),
    );
  }

  factory SpotProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpotProgressData(
      memberId: serializer.fromJson<String>(json['memberId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      seenCount: serializer.fromJson<int>(json['seenCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberId': serializer.toJson<String>(memberId),
      'questionId': serializer.toJson<String>(questionId),
      'seenCount': serializer.toJson<int>(seenCount),
      'correctCount': serializer.toJson<int>(correctCount),
    };
  }

  SpotProgressData copyWith(
          {String? memberId,
          String? questionId,
          int? seenCount,
          int? correctCount}) =>
      SpotProgressData(
        memberId: memberId ?? this.memberId,
        questionId: questionId ?? this.questionId,
        seenCount: seenCount ?? this.seenCount,
        correctCount: correctCount ?? this.correctCount,
      );
  SpotProgressData copyWithCompanion(SpotProgressCompanion data) {
    return SpotProgressData(
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      seenCount: data.seenCount.present ? data.seenCount.value : this.seenCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpotProgressData(')
          ..write('memberId: $memberId, ')
          ..write('questionId: $questionId, ')
          ..write('seenCount: $seenCount, ')
          ..write('correctCount: $correctCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(memberId, questionId, seenCount, correctCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpotProgressData &&
          other.memberId == this.memberId &&
          other.questionId == this.questionId &&
          other.seenCount == this.seenCount &&
          other.correctCount == this.correctCount);
}

class SpotProgressCompanion extends UpdateCompanion<SpotProgressData> {
  final Value<String> memberId;
  final Value<String> questionId;
  final Value<int> seenCount;
  final Value<int> correctCount;
  final Value<int> rowid;
  const SpotProgressCompanion({
    this.memberId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.seenCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpotProgressCompanion.insert({
    required String memberId,
    required String questionId,
    this.seenCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : memberId = Value(memberId),
        questionId = Value(questionId);
  static Insertable<SpotProgressData> custom({
    Expression<String>? memberId,
    Expression<String>? questionId,
    Expression<int>? seenCount,
    Expression<int>? correctCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memberId != null) 'member_id': memberId,
      if (questionId != null) 'question_id': questionId,
      if (seenCount != null) 'seen_count': seenCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpotProgressCompanion copyWith(
      {Value<String>? memberId,
      Value<String>? questionId,
      Value<int>? seenCount,
      Value<int>? correctCount,
      Value<int>? rowid}) {
    return SpotProgressCompanion(
      memberId: memberId ?? this.memberId,
      questionId: questionId ?? this.questionId,
      seenCount: seenCount ?? this.seenCount,
      correctCount: correctCount ?? this.correctCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (seenCount.present) {
      map['seen_count'] = Variable<int>(seenCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpotProgressCompanion(')
          ..write('memberId: $memberId, ')
          ..write('questionId: $questionId, ')
          ..write('seenCount: $seenCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadProgressTable extends ReadProgress
    with TableInfo<$ReadProgressTable, ReadProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _knewItMeta = const VerificationMeta('knewIt');
  @override
  late final GeneratedColumn<bool> knewIt = GeneratedColumn<bool>(
      'knew_it', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("knew_it" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [memberId, itemId, knewIt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_progress';
  @override
  VerificationContext validateIntegrity(Insertable<ReadProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('knew_it')) {
      context.handle(_knewItMeta,
          knewIt.isAcceptableOrUnknown(data['knew_it']!, _knewItMeta));
    } else if (isInserting) {
      context.missing(_knewItMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberId, itemId};
  @override
  ReadProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadProgressData(
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      knewIt: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}knew_it'])!,
    );
  }

  @override
  $ReadProgressTable createAlias(String alias) {
    return $ReadProgressTable(attachedDatabase, alias);
  }
}

class ReadProgressData extends DataClass
    implements Insertable<ReadProgressData> {
  final String memberId;
  final String itemId;
  final bool knewIt;
  const ReadProgressData(
      {required this.memberId, required this.itemId, required this.knewIt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['member_id'] = Variable<String>(memberId);
    map['item_id'] = Variable<String>(itemId);
    map['knew_it'] = Variable<bool>(knewIt);
    return map;
  }

  ReadProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadProgressCompanion(
      memberId: Value(memberId),
      itemId: Value(itemId),
      knewIt: Value(knewIt),
    );
  }

  factory ReadProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadProgressData(
      memberId: serializer.fromJson<String>(json['memberId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      knewIt: serializer.fromJson<bool>(json['knewIt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberId': serializer.toJson<String>(memberId),
      'itemId': serializer.toJson<String>(itemId),
      'knewIt': serializer.toJson<bool>(knewIt),
    };
  }

  ReadProgressData copyWith({String? memberId, String? itemId, bool? knewIt}) =>
      ReadProgressData(
        memberId: memberId ?? this.memberId,
        itemId: itemId ?? this.itemId,
        knewIt: knewIt ?? this.knewIt,
      );
  ReadProgressData copyWithCompanion(ReadProgressCompanion data) {
    return ReadProgressData(
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      knewIt: data.knewIt.present ? data.knewIt.value : this.knewIt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadProgressData(')
          ..write('memberId: $memberId, ')
          ..write('itemId: $itemId, ')
          ..write('knewIt: $knewIt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(memberId, itemId, knewIt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadProgressData &&
          other.memberId == this.memberId &&
          other.itemId == this.itemId &&
          other.knewIt == this.knewIt);
}

class ReadProgressCompanion extends UpdateCompanion<ReadProgressData> {
  final Value<String> memberId;
  final Value<String> itemId;
  final Value<bool> knewIt;
  final Value<int> rowid;
  const ReadProgressCompanion({
    this.memberId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.knewIt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadProgressCompanion.insert({
    required String memberId,
    required String itemId,
    required bool knewIt,
    this.rowid = const Value.absent(),
  })  : memberId = Value(memberId),
        itemId = Value(itemId),
        knewIt = Value(knewIt);
  static Insertable<ReadProgressData> custom({
    Expression<String>? memberId,
    Expression<String>? itemId,
    Expression<bool>? knewIt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memberId != null) 'member_id': memberId,
      if (itemId != null) 'item_id': itemId,
      if (knewIt != null) 'knew_it': knewIt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadProgressCompanion copyWith(
      {Value<String>? memberId,
      Value<String>? itemId,
      Value<bool>? knewIt,
      Value<int>? rowid}) {
    return ReadProgressCompanion(
      memberId: memberId ?? this.memberId,
      itemId: itemId ?? this.itemId,
      knewIt: knewIt ?? this.knewIt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (knewIt.present) {
      map['knew_it'] = Variable<bool>(knewIt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadProgressCompanion(')
          ..write('memberId: $memberId, ')
          ..write('itemId: $itemId, ')
          ..write('knewIt: $knewIt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiscoveredThroughlinesTable extends DiscoveredThroughlines
    with TableInfo<$DiscoveredThroughlinesTable, DiscoveredThroughline> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveredThroughlinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _throughlineIdMeta =
      const VerificationMeta('throughlineId');
  @override
  late final GeneratedColumn<String> throughlineId = GeneratedColumn<String>(
      'throughline_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstSeenAtMeta =
      const VerificationMeta('firstSeenAt');
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
      'first_seen_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [memberId, throughlineId, firstSeenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovered_throughlines';
  @override
  VerificationContext validateIntegrity(
      Insertable<DiscoveredThroughline> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('throughline_id')) {
      context.handle(
          _throughlineIdMeta,
          throughlineId.isAcceptableOrUnknown(
              data['throughline_id']!, _throughlineIdMeta));
    } else if (isInserting) {
      context.missing(_throughlineIdMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
          _firstSeenAtMeta,
          firstSeenAt.isAcceptableOrUnknown(
              data['first_seen_at']!, _firstSeenAtMeta));
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberId, throughlineId};
  @override
  DiscoveredThroughline map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveredThroughline(
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      throughlineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}throughline_id'])!,
      firstSeenAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_seen_at'])!,
    );
  }

  @override
  $DiscoveredThroughlinesTable createAlias(String alias) {
    return $DiscoveredThroughlinesTable(attachedDatabase, alias);
  }
}

class DiscoveredThroughline extends DataClass
    implements Insertable<DiscoveredThroughline> {
  final String memberId;
  final String throughlineId;
  final DateTime firstSeenAt;
  const DiscoveredThroughline(
      {required this.memberId,
      required this.throughlineId,
      required this.firstSeenAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['member_id'] = Variable<String>(memberId);
    map['throughline_id'] = Variable<String>(throughlineId);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    return map;
  }

  DiscoveredThroughlinesCompanion toCompanion(bool nullToAbsent) {
    return DiscoveredThroughlinesCompanion(
      memberId: Value(memberId),
      throughlineId: Value(throughlineId),
      firstSeenAt: Value(firstSeenAt),
    );
  }

  factory DiscoveredThroughline.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveredThroughline(
      memberId: serializer.fromJson<String>(json['memberId']),
      throughlineId: serializer.fromJson<String>(json['throughlineId']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberId': serializer.toJson<String>(memberId),
      'throughlineId': serializer.toJson<String>(throughlineId),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
    };
  }

  DiscoveredThroughline copyWith(
          {String? memberId, String? throughlineId, DateTime? firstSeenAt}) =>
      DiscoveredThroughline(
        memberId: memberId ?? this.memberId,
        throughlineId: throughlineId ?? this.throughlineId,
        firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      );
  DiscoveredThroughline copyWithCompanion(
      DiscoveredThroughlinesCompanion data) {
    return DiscoveredThroughline(
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      throughlineId: data.throughlineId.present
          ? data.throughlineId.value
          : this.throughlineId,
      firstSeenAt:
          data.firstSeenAt.present ? data.firstSeenAt.value : this.firstSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredThroughline(')
          ..write('memberId: $memberId, ')
          ..write('throughlineId: $throughlineId, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(memberId, throughlineId, firstSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveredThroughline &&
          other.memberId == this.memberId &&
          other.throughlineId == this.throughlineId &&
          other.firstSeenAt == this.firstSeenAt);
}

class DiscoveredThroughlinesCompanion
    extends UpdateCompanion<DiscoveredThroughline> {
  final Value<String> memberId;
  final Value<String> throughlineId;
  final Value<DateTime> firstSeenAt;
  final Value<int> rowid;
  const DiscoveredThroughlinesCompanion({
    this.memberId = const Value.absent(),
    this.throughlineId = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscoveredThroughlinesCompanion.insert({
    required String memberId,
    required String throughlineId,
    required DateTime firstSeenAt,
    this.rowid = const Value.absent(),
  })  : memberId = Value(memberId),
        throughlineId = Value(throughlineId),
        firstSeenAt = Value(firstSeenAt);
  static Insertable<DiscoveredThroughline> custom({
    Expression<String>? memberId,
    Expression<String>? throughlineId,
    Expression<DateTime>? firstSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memberId != null) 'member_id': memberId,
      if (throughlineId != null) 'throughline_id': throughlineId,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscoveredThroughlinesCompanion copyWith(
      {Value<String>? memberId,
      Value<String>? throughlineId,
      Value<DateTime>? firstSeenAt,
      Value<int>? rowid}) {
    return DiscoveredThroughlinesCompanion(
      memberId: memberId ?? this.memberId,
      throughlineId: throughlineId ?? this.throughlineId,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (throughlineId.present) {
      map['throughline_id'] = Variable<String>(throughlineId.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredThroughlinesCompanion(')
          ..write('memberId: $memberId, ')
          ..write('throughlineId: $throughlineId, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MantleDatabase extends GeneratedDatabase {
  _$MantleDatabase(QueryExecutor e) : super(e);
  $MantleDatabaseManager get managers => $MantleDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $RoundsTable rounds = $RoundsTable(this);
  late final $RankingSessionsTable rankingSessions =
      $RankingSessionsTable(this);
  late final $RankingMatchesTable rankingMatches = $RankingMatchesTable(this);
  late final $ChartersTable charters = $ChartersTable(this);
  late final $SpotProgressTable spotProgress = $SpotProgressTable(this);
  late final $ReadProgressTable readProgress = $ReadProgressTable(this);
  late final $DiscoveredThroughlinesTable discoveredThroughlines =
      $DiscoveredThroughlinesTable(this);
  late final Index idxMatchesSession = Index('idx_matches_session',
      'CREATE INDEX idx_matches_session ON ranking_matches (session_id)');
  late final MembersDao membersDao = MembersDao(this as MantleDatabase);
  late final RoundsDao roundsDao = RoundsDao(this as MantleDatabase);
  late final SessionsDao sessionsDao = SessionsDao(this as MantleDatabase);
  late final MatchesDao matchesDao = MatchesDao(this as MantleDatabase);
  late final ChartersDao chartersDao = ChartersDao(this as MantleDatabase);
  late final ReadProgressDao readProgressDao =
      ReadProgressDao(this as MantleDatabase);
  late final SpotProgressDao spotProgressDao =
      SpotProgressDao(this as MantleDatabase);
  late final DiscoveredThroughlinesDao discoveredThroughlinesDao =
      DiscoveredThroughlinesDao(this as MantleDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        members,
        rounds,
        rankingSessions,
        rankingMatches,
        charters,
        spotProgress,
        readProgress,
        discoveredThroughlines,
        idxMatchesSession
      ];
}

typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  required String label,
  required int color,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<int> color,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MembersTableFilterComposer
    extends Composer<_$MantleDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MembersTableOrderingComposer
    extends Composer<_$MantleDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$MantleDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MembersTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $MembersTable,
    MemberRow,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (MemberRow, BaseReferences<_$MantleDatabase, $MembersTable, MemberRow>),
    MemberRow,
    PrefetchHooks Function()> {
  $$MembersTableTableManager(_$MantleDatabase db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion(
            id: id,
            label: label,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String label,
            required int color,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion.insert(
            id: id,
            label: label,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $MembersTable,
    MemberRow,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (MemberRow, BaseReferences<_$MantleDatabase, $MembersTable, MemberRow>),
    MemberRow,
    PrefetchHooks Function()>;
typedef $$RoundsTableCreateCompanionBuilder = RoundsCompanion Function({
  required String id,
  required int deckVersion,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RoundsTableUpdateCompanionBuilder = RoundsCompanion Function({
  Value<String> id,
  Value<int> deckVersion,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RoundsTableFilterComposer
    extends Composer<_$MantleDatabase, $RoundsTable> {
  $$RoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deckVersion => $composableBuilder(
      column: $table.deckVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RoundsTableOrderingComposer
    extends Composer<_$MantleDatabase, $RoundsTable> {
  $$RoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deckVersion => $composableBuilder(
      column: $table.deckVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RoundsTableAnnotationComposer
    extends Composer<_$MantleDatabase, $RoundsTable> {
  $$RoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get deckVersion => $composableBuilder(
      column: $table.deckVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RoundsTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $RoundsTable,
    Round,
    $$RoundsTableFilterComposer,
    $$RoundsTableOrderingComposer,
    $$RoundsTableAnnotationComposer,
    $$RoundsTableCreateCompanionBuilder,
    $$RoundsTableUpdateCompanionBuilder,
    (Round, BaseReferences<_$MantleDatabase, $RoundsTable, Round>),
    Round,
    PrefetchHooks Function()> {
  $$RoundsTableTableManager(_$MantleDatabase db, $RoundsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> deckVersion = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundsCompanion(
            id: id,
            deckVersion: deckVersion,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int deckVersion,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundsCompanion.insert(
            id: id,
            deckVersion: deckVersion,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RoundsTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $RoundsTable,
    Round,
    $$RoundsTableFilterComposer,
    $$RoundsTableOrderingComposer,
    $$RoundsTableAnnotationComposer,
    $$RoundsTableCreateCompanionBuilder,
    $$RoundsTableUpdateCompanionBuilder,
    (Round, BaseReferences<_$MantleDatabase, $RoundsTable, Round>),
    Round,
    PrefetchHooks Function()>;
typedef $$RankingSessionsTableCreateCompanionBuilder = RankingSessionsCompanion
    Function({
  required String id,
  required String roundId,
  required String memberId,
  required String domain,
  Value<bool> isComplete,
  Value<bool> resultsLocked,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RankingSessionsTableUpdateCompanionBuilder = RankingSessionsCompanion
    Function({
  Value<String> id,
  Value<String> roundId,
  Value<String> memberId,
  Value<String> domain,
  Value<bool> isComplete,
  Value<bool> resultsLocked,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RankingSessionsTableFilterComposer
    extends Composer<_$MantleDatabase, $RankingSessionsTable> {
  $$RankingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roundId => $composableBuilder(
      column: $table.roundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get resultsLocked => $composableBuilder(
      column: $table.resultsLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RankingSessionsTableOrderingComposer
    extends Composer<_$MantleDatabase, $RankingSessionsTable> {
  $$RankingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roundId => $composableBuilder(
      column: $table.roundId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get resultsLocked => $composableBuilder(
      column: $table.resultsLocked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RankingSessionsTableAnnotationComposer
    extends Composer<_$MantleDatabase, $RankingSessionsTable> {
  $$RankingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roundId =>
      $composableBuilder(column: $table.roundId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => column);

  GeneratedColumn<bool> get resultsLocked => $composableBuilder(
      column: $table.resultsLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RankingSessionsTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $RankingSessionsTable,
    RankingSession,
    $$RankingSessionsTableFilterComposer,
    $$RankingSessionsTableOrderingComposer,
    $$RankingSessionsTableAnnotationComposer,
    $$RankingSessionsTableCreateCompanionBuilder,
    $$RankingSessionsTableUpdateCompanionBuilder,
    (
      RankingSession,
      BaseReferences<_$MantleDatabase, $RankingSessionsTable, RankingSession>
    ),
    RankingSession,
    PrefetchHooks Function()> {
  $$RankingSessionsTableTableManager(
      _$MantleDatabase db, $RankingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RankingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RankingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RankingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> roundId = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<String> domain = const Value.absent(),
            Value<bool> isComplete = const Value.absent(),
            Value<bool> resultsLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RankingSessionsCompanion(
            id: id,
            roundId: roundId,
            memberId: memberId,
            domain: domain,
            isComplete: isComplete,
            resultsLocked: resultsLocked,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String roundId,
            required String memberId,
            required String domain,
            Value<bool> isComplete = const Value.absent(),
            Value<bool> resultsLocked = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RankingSessionsCompanion.insert(
            id: id,
            roundId: roundId,
            memberId: memberId,
            domain: domain,
            isComplete: isComplete,
            resultsLocked: resultsLocked,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RankingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $RankingSessionsTable,
    RankingSession,
    $$RankingSessionsTableFilterComposer,
    $$RankingSessionsTableOrderingComposer,
    $$RankingSessionsTableAnnotationComposer,
    $$RankingSessionsTableCreateCompanionBuilder,
    $$RankingSessionsTableUpdateCompanionBuilder,
    (
      RankingSession,
      BaseReferences<_$MantleDatabase, $RankingSessionsTable, RankingSession>
    ),
    RankingSession,
    PrefetchHooks Function()>;
typedef $$RankingMatchesTableCreateCompanionBuilder = RankingMatchesCompanion
    Function({
  required String id,
  required String sessionId,
  required String idA,
  required String idB,
  required String outcome,
  required DateTime decidedAt,
  Value<int> rowid,
});
typedef $$RankingMatchesTableUpdateCompanionBuilder = RankingMatchesCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> idA,
  Value<String> idB,
  Value<String> outcome,
  Value<DateTime> decidedAt,
  Value<int> rowid,
});

class $$RankingMatchesTableFilterComposer
    extends Composer<_$MantleDatabase, $RankingMatchesTable> {
  $$RankingMatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idA => $composableBuilder(
      column: $table.idA, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idB => $composableBuilder(
      column: $table.idB, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
      column: $table.decidedAt, builder: (column) => ColumnFilters(column));
}

class $$RankingMatchesTableOrderingComposer
    extends Composer<_$MantleDatabase, $RankingMatchesTable> {
  $$RankingMatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idA => $composableBuilder(
      column: $table.idA, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idB => $composableBuilder(
      column: $table.idB, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
      column: $table.decidedAt, builder: (column) => ColumnOrderings(column));
}

class $$RankingMatchesTableAnnotationComposer
    extends Composer<_$MantleDatabase, $RankingMatchesTable> {
  $$RankingMatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get idA =>
      $composableBuilder(column: $table.idA, builder: (column) => column);

  GeneratedColumn<String> get idB =>
      $composableBuilder(column: $table.idB, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$RankingMatchesTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $RankingMatchesTable,
    RankingMatch,
    $$RankingMatchesTableFilterComposer,
    $$RankingMatchesTableOrderingComposer,
    $$RankingMatchesTableAnnotationComposer,
    $$RankingMatchesTableCreateCompanionBuilder,
    $$RankingMatchesTableUpdateCompanionBuilder,
    (
      RankingMatch,
      BaseReferences<_$MantleDatabase, $RankingMatchesTable, RankingMatch>
    ),
    RankingMatch,
    PrefetchHooks Function()> {
  $$RankingMatchesTableTableManager(
      _$MantleDatabase db, $RankingMatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RankingMatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RankingMatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RankingMatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> idA = const Value.absent(),
            Value<String> idB = const Value.absent(),
            Value<String> outcome = const Value.absent(),
            Value<DateTime> decidedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RankingMatchesCompanion(
            id: id,
            sessionId: sessionId,
            idA: idA,
            idB: idB,
            outcome: outcome,
            decidedAt: decidedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String idA,
            required String idB,
            required String outcome,
            required DateTime decidedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RankingMatchesCompanion.insert(
            id: id,
            sessionId: sessionId,
            idA: idA,
            idB: idB,
            outcome: outcome,
            decidedAt: decidedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RankingMatchesTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $RankingMatchesTable,
    RankingMatch,
    $$RankingMatchesTableFilterComposer,
    $$RankingMatchesTableOrderingComposer,
    $$RankingMatchesTableAnnotationComposer,
    $$RankingMatchesTableCreateCompanionBuilder,
    $$RankingMatchesTableUpdateCompanionBuilder,
    (
      RankingMatch,
      BaseReferences<_$MantleDatabase, $RankingMatchesTable, RankingMatch>
    ),
    RankingMatch,
    PrefetchHooks Function()>;
typedef $$ChartersTableCreateCompanionBuilder = ChartersCompanion Function({
  required String id,
  required String roundId,
  Value<String> houseName,
  Value<String> motto,
  required DateTime createdAt,
  required String spineItemIds,
  required String throughlines,
  required String contestedItemIds,
  Value<String> bodyOverrides,
  Value<int> rowid,
});
typedef $$ChartersTableUpdateCompanionBuilder = ChartersCompanion Function({
  Value<String> id,
  Value<String> roundId,
  Value<String> houseName,
  Value<String> motto,
  Value<DateTime> createdAt,
  Value<String> spineItemIds,
  Value<String> throughlines,
  Value<String> contestedItemIds,
  Value<String> bodyOverrides,
  Value<int> rowid,
});

class $$ChartersTableFilterComposer
    extends Composer<_$MantleDatabase, $ChartersTable> {
  $$ChartersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roundId => $composableBuilder(
      column: $table.roundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get houseName => $composableBuilder(
      column: $table.houseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motto => $composableBuilder(
      column: $table.motto, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spineItemIds => $composableBuilder(
      column: $table.spineItemIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get throughlines => $composableBuilder(
      column: $table.throughlines, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contestedItemIds => $composableBuilder(
      column: $table.contestedItemIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyOverrides => $composableBuilder(
      column: $table.bodyOverrides, builder: (column) => ColumnFilters(column));
}

class $$ChartersTableOrderingComposer
    extends Composer<_$MantleDatabase, $ChartersTable> {
  $$ChartersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roundId => $composableBuilder(
      column: $table.roundId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get houseName => $composableBuilder(
      column: $table.houseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motto => $composableBuilder(
      column: $table.motto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spineItemIds => $composableBuilder(
      column: $table.spineItemIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get throughlines => $composableBuilder(
      column: $table.throughlines,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contestedItemIds => $composableBuilder(
      column: $table.contestedItemIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyOverrides => $composableBuilder(
      column: $table.bodyOverrides,
      builder: (column) => ColumnOrderings(column));
}

class $$ChartersTableAnnotationComposer
    extends Composer<_$MantleDatabase, $ChartersTable> {
  $$ChartersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roundId =>
      $composableBuilder(column: $table.roundId, builder: (column) => column);

  GeneratedColumn<String> get houseName =>
      $composableBuilder(column: $table.houseName, builder: (column) => column);

  GeneratedColumn<String> get motto =>
      $composableBuilder(column: $table.motto, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get spineItemIds => $composableBuilder(
      column: $table.spineItemIds, builder: (column) => column);

  GeneratedColumn<String> get throughlines => $composableBuilder(
      column: $table.throughlines, builder: (column) => column);

  GeneratedColumn<String> get contestedItemIds => $composableBuilder(
      column: $table.contestedItemIds, builder: (column) => column);

  GeneratedColumn<String> get bodyOverrides => $composableBuilder(
      column: $table.bodyOverrides, builder: (column) => column);
}

class $$ChartersTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $ChartersTable,
    Charter,
    $$ChartersTableFilterComposer,
    $$ChartersTableOrderingComposer,
    $$ChartersTableAnnotationComposer,
    $$ChartersTableCreateCompanionBuilder,
    $$ChartersTableUpdateCompanionBuilder,
    (Charter, BaseReferences<_$MantleDatabase, $ChartersTable, Charter>),
    Charter,
    PrefetchHooks Function()> {
  $$ChartersTableTableManager(_$MantleDatabase db, $ChartersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChartersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChartersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChartersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> roundId = const Value.absent(),
            Value<String> houseName = const Value.absent(),
            Value<String> motto = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> spineItemIds = const Value.absent(),
            Value<String> throughlines = const Value.absent(),
            Value<String> contestedItemIds = const Value.absent(),
            Value<String> bodyOverrides = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChartersCompanion(
            id: id,
            roundId: roundId,
            houseName: houseName,
            motto: motto,
            createdAt: createdAt,
            spineItemIds: spineItemIds,
            throughlines: throughlines,
            contestedItemIds: contestedItemIds,
            bodyOverrides: bodyOverrides,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String roundId,
            Value<String> houseName = const Value.absent(),
            Value<String> motto = const Value.absent(),
            required DateTime createdAt,
            required String spineItemIds,
            required String throughlines,
            required String contestedItemIds,
            Value<String> bodyOverrides = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChartersCompanion.insert(
            id: id,
            roundId: roundId,
            houseName: houseName,
            motto: motto,
            createdAt: createdAt,
            spineItemIds: spineItemIds,
            throughlines: throughlines,
            contestedItemIds: contestedItemIds,
            bodyOverrides: bodyOverrides,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChartersTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $ChartersTable,
    Charter,
    $$ChartersTableFilterComposer,
    $$ChartersTableOrderingComposer,
    $$ChartersTableAnnotationComposer,
    $$ChartersTableCreateCompanionBuilder,
    $$ChartersTableUpdateCompanionBuilder,
    (Charter, BaseReferences<_$MantleDatabase, $ChartersTable, Charter>),
    Charter,
    PrefetchHooks Function()>;
typedef $$SpotProgressTableCreateCompanionBuilder = SpotProgressCompanion
    Function({
  required String memberId,
  required String questionId,
  Value<int> seenCount,
  Value<int> correctCount,
  Value<int> rowid,
});
typedef $$SpotProgressTableUpdateCompanionBuilder = SpotProgressCompanion
    Function({
  Value<String> memberId,
  Value<String> questionId,
  Value<int> seenCount,
  Value<int> correctCount,
  Value<int> rowid,
});

class $$SpotProgressTableFilterComposer
    extends Composer<_$MantleDatabase, $SpotProgressTable> {
  $$SpotProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seenCount => $composableBuilder(
      column: $table.seenCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => ColumnFilters(column));
}

class $$SpotProgressTableOrderingComposer
    extends Composer<_$MantleDatabase, $SpotProgressTable> {
  $$SpotProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seenCount => $composableBuilder(
      column: $table.seenCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctCount => $composableBuilder(
      column: $table.correctCount,
      builder: (column) => ColumnOrderings(column));
}

class $$SpotProgressTableAnnotationComposer
    extends Composer<_$MantleDatabase, $SpotProgressTable> {
  $$SpotProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<int> get seenCount =>
      $composableBuilder(column: $table.seenCount, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => column);
}

class $$SpotProgressTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $SpotProgressTable,
    SpotProgressData,
    $$SpotProgressTableFilterComposer,
    $$SpotProgressTableOrderingComposer,
    $$SpotProgressTableAnnotationComposer,
    $$SpotProgressTableCreateCompanionBuilder,
    $$SpotProgressTableUpdateCompanionBuilder,
    (
      SpotProgressData,
      BaseReferences<_$MantleDatabase, $SpotProgressTable, SpotProgressData>
    ),
    SpotProgressData,
    PrefetchHooks Function()> {
  $$SpotProgressTableTableManager(_$MantleDatabase db, $SpotProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpotProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpotProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpotProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> memberId = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<int> seenCount = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpotProgressCompanion(
            memberId: memberId,
            questionId: questionId,
            seenCount: seenCount,
            correctCount: correctCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String memberId,
            required String questionId,
            Value<int> seenCount = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpotProgressCompanion.insert(
            memberId: memberId,
            questionId: questionId,
            seenCount: seenCount,
            correctCount: correctCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SpotProgressTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $SpotProgressTable,
    SpotProgressData,
    $$SpotProgressTableFilterComposer,
    $$SpotProgressTableOrderingComposer,
    $$SpotProgressTableAnnotationComposer,
    $$SpotProgressTableCreateCompanionBuilder,
    $$SpotProgressTableUpdateCompanionBuilder,
    (
      SpotProgressData,
      BaseReferences<_$MantleDatabase, $SpotProgressTable, SpotProgressData>
    ),
    SpotProgressData,
    PrefetchHooks Function()>;
typedef $$ReadProgressTableCreateCompanionBuilder = ReadProgressCompanion
    Function({
  required String memberId,
  required String itemId,
  required bool knewIt,
  Value<int> rowid,
});
typedef $$ReadProgressTableUpdateCompanionBuilder = ReadProgressCompanion
    Function({
  Value<String> memberId,
  Value<String> itemId,
  Value<bool> knewIt,
  Value<int> rowid,
});

class $$ReadProgressTableFilterComposer
    extends Composer<_$MantleDatabase, $ReadProgressTable> {
  $$ReadProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get knewIt => $composableBuilder(
      column: $table.knewIt, builder: (column) => ColumnFilters(column));
}

class $$ReadProgressTableOrderingComposer
    extends Composer<_$MantleDatabase, $ReadProgressTable> {
  $$ReadProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get knewIt => $composableBuilder(
      column: $table.knewIt, builder: (column) => ColumnOrderings(column));
}

class $$ReadProgressTableAnnotationComposer
    extends Composer<_$MantleDatabase, $ReadProgressTable> {
  $$ReadProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<bool> get knewIt =>
      $composableBuilder(column: $table.knewIt, builder: (column) => column);
}

class $$ReadProgressTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $ReadProgressTable,
    ReadProgressData,
    $$ReadProgressTableFilterComposer,
    $$ReadProgressTableOrderingComposer,
    $$ReadProgressTableAnnotationComposer,
    $$ReadProgressTableCreateCompanionBuilder,
    $$ReadProgressTableUpdateCompanionBuilder,
    (
      ReadProgressData,
      BaseReferences<_$MantleDatabase, $ReadProgressTable, ReadProgressData>
    ),
    ReadProgressData,
    PrefetchHooks Function()> {
  $$ReadProgressTableTableManager(_$MantleDatabase db, $ReadProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> memberId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<bool> knewIt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadProgressCompanion(
            memberId: memberId,
            itemId: itemId,
            knewIt: knewIt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String memberId,
            required String itemId,
            required bool knewIt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadProgressCompanion.insert(
            memberId: memberId,
            itemId: itemId,
            knewIt: knewIt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadProgressTableProcessedTableManager = ProcessedTableManager<
    _$MantleDatabase,
    $ReadProgressTable,
    ReadProgressData,
    $$ReadProgressTableFilterComposer,
    $$ReadProgressTableOrderingComposer,
    $$ReadProgressTableAnnotationComposer,
    $$ReadProgressTableCreateCompanionBuilder,
    $$ReadProgressTableUpdateCompanionBuilder,
    (
      ReadProgressData,
      BaseReferences<_$MantleDatabase, $ReadProgressTable, ReadProgressData>
    ),
    ReadProgressData,
    PrefetchHooks Function()>;
typedef $$DiscoveredThroughlinesTableCreateCompanionBuilder
    = DiscoveredThroughlinesCompanion Function({
  required String memberId,
  required String throughlineId,
  required DateTime firstSeenAt,
  Value<int> rowid,
});
typedef $$DiscoveredThroughlinesTableUpdateCompanionBuilder
    = DiscoveredThroughlinesCompanion Function({
  Value<String> memberId,
  Value<String> throughlineId,
  Value<DateTime> firstSeenAt,
  Value<int> rowid,
});

class $$DiscoveredThroughlinesTableFilterComposer
    extends Composer<_$MantleDatabase, $DiscoveredThroughlinesTable> {
  $$DiscoveredThroughlinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get throughlineId => $composableBuilder(
      column: $table.throughlineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
      column: $table.firstSeenAt, builder: (column) => ColumnFilters(column));
}

class $$DiscoveredThroughlinesTableOrderingComposer
    extends Composer<_$MantleDatabase, $DiscoveredThroughlinesTable> {
  $$DiscoveredThroughlinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get throughlineId => $composableBuilder(
      column: $table.throughlineId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
      column: $table.firstSeenAt, builder: (column) => ColumnOrderings(column));
}

class $$DiscoveredThroughlinesTableAnnotationComposer
    extends Composer<_$MantleDatabase, $DiscoveredThroughlinesTable> {
  $$DiscoveredThroughlinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get throughlineId => $composableBuilder(
      column: $table.throughlineId, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
      column: $table.firstSeenAt, builder: (column) => column);
}

class $$DiscoveredThroughlinesTableTableManager extends RootTableManager<
    _$MantleDatabase,
    $DiscoveredThroughlinesTable,
    DiscoveredThroughline,
    $$DiscoveredThroughlinesTableFilterComposer,
    $$DiscoveredThroughlinesTableOrderingComposer,
    $$DiscoveredThroughlinesTableAnnotationComposer,
    $$DiscoveredThroughlinesTableCreateCompanionBuilder,
    $$DiscoveredThroughlinesTableUpdateCompanionBuilder,
    (
      DiscoveredThroughline,
      BaseReferences<_$MantleDatabase, $DiscoveredThroughlinesTable,
          DiscoveredThroughline>
    ),
    DiscoveredThroughline,
    PrefetchHooks Function()> {
  $$DiscoveredThroughlinesTableTableManager(
      _$MantleDatabase db, $DiscoveredThroughlinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveredThroughlinesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveredThroughlinesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveredThroughlinesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> memberId = const Value.absent(),
            Value<String> throughlineId = const Value.absent(),
            Value<DateTime> firstSeenAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiscoveredThroughlinesCompanion(
            memberId: memberId,
            throughlineId: throughlineId,
            firstSeenAt: firstSeenAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String memberId,
            required String throughlineId,
            required DateTime firstSeenAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DiscoveredThroughlinesCompanion.insert(
            memberId: memberId,
            throughlineId: throughlineId,
            firstSeenAt: firstSeenAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiscoveredThroughlinesTableProcessedTableManager
    = ProcessedTableManager<
        _$MantleDatabase,
        $DiscoveredThroughlinesTable,
        DiscoveredThroughline,
        $$DiscoveredThroughlinesTableFilterComposer,
        $$DiscoveredThroughlinesTableOrderingComposer,
        $$DiscoveredThroughlinesTableAnnotationComposer,
        $$DiscoveredThroughlinesTableCreateCompanionBuilder,
        $$DiscoveredThroughlinesTableUpdateCompanionBuilder,
        (
          DiscoveredThroughline,
          BaseReferences<_$MantleDatabase, $DiscoveredThroughlinesTable,
              DiscoveredThroughline>
        ),
        DiscoveredThroughline,
        PrefetchHooks Function()>;

class $MantleDatabaseManager {
  final _$MantleDatabase _db;
  $MantleDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$RoundsTableTableManager get rounds =>
      $$RoundsTableTableManager(_db, _db.rounds);
  $$RankingSessionsTableTableManager get rankingSessions =>
      $$RankingSessionsTableTableManager(_db, _db.rankingSessions);
  $$RankingMatchesTableTableManager get rankingMatches =>
      $$RankingMatchesTableTableManager(_db, _db.rankingMatches);
  $$ChartersTableTableManager get charters =>
      $$ChartersTableTableManager(_db, _db.charters);
  $$SpotProgressTableTableManager get spotProgress =>
      $$SpotProgressTableTableManager(_db, _db.spotProgress);
  $$ReadProgressTableTableManager get readProgress =>
      $$ReadProgressTableTableManager(_db, _db.readProgress);
  $$DiscoveredThroughlinesTableTableManager get discoveredThroughlines =>
      $$DiscoveredThroughlinesTableTableManager(
          _db, _db.discoveredThroughlines);
}
