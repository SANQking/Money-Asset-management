// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AssetRowsTable extends AssetRows
    with TableInfo<$AssetRowsTable, AssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<String> purchaseDate = GeneratedColumn<String>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuationDateMeta = const VerificationMeta(
    'valuationDate',
  );
  @override
  late final GeneratedColumn<String> valuationDate = GeneratedColumn<String>(
    'valuation_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _warrantyUntilMeta = const VerificationMeta(
    'warrantyUntil',
  );
  @override
  late final GeneratedColumn<String> warrantyUntil = GeneratedColumn<String>(
    'warranty_until',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastUsedDateMeta = const VerificationMeta(
    'lastUsedDate',
  );
  @override
  late final GeneratedColumn<String> lastUsedDate = GeneratedColumn<String>(
    'last_used_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _soldDateMeta = const VerificationMeta(
    'soldDate',
  );
  @override
  late final GeneratedColumn<String> soldDate = GeneratedColumn<String>(
    'sold_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    purchasePrice,
    purchaseDate,
    category,
    status,
    currentValue,
    valuationDate,
    warrantyUntil,
    lastUsedDate,
    tagsJson,
    image,
    soldDate,
    salePrice,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('valuation_date')) {
      context.handle(
        _valuationDateMeta,
        valuationDate.isAcceptableOrUnknown(
          data['valuation_date']!,
          _valuationDateMeta,
        ),
      );
    }
    if (data.containsKey('warranty_until')) {
      context.handle(
        _warrantyUntilMeta,
        warrantyUntil.isAcceptableOrUnknown(
          data['warranty_until']!,
          _warrantyUntilMeta,
        ),
      );
    }
    if (data.containsKey('last_used_date')) {
      context.handle(
        _lastUsedDateMeta,
        lastUsedDate.isAcceptableOrUnknown(
          data['last_used_date']!,
          _lastUsedDateMeta,
        ),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('sold_date')) {
      context.handle(
        _soldDateMeta,
        soldDate.isAcceptableOrUnknown(data['sold_date']!, _soldDateMeta),
      );
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      valuationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valuation_date'],
      )!,
      warrantyUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_until'],
      )!,
      lastUsedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_used_date'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
      soldDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sold_date'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_price'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $AssetRowsTable createAlias(String alias) {
    return $AssetRowsTable(attachedDatabase, alias);
  }
}

class AssetRow extends DataClass implements Insertable<AssetRow> {
  final String id;
  final String name;
  final double purchasePrice;
  final String purchaseDate;
  final String category;
  final String status;
  final double currentValue;
  final String valuationDate;
  final String warrantyUntil;
  final String lastUsedDate;
  final String tagsJson;
  final String image;
  final String soldDate;
  final double salePrice;
  final String notes;
  const AssetRow({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.category,
    required this.status,
    required this.currentValue,
    required this.valuationDate,
    required this.warrantyUntil,
    required this.lastUsedDate,
    required this.tagsJson,
    required this.image,
    required this.soldDate,
    required this.salePrice,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['purchase_date'] = Variable<String>(purchaseDate);
    map['category'] = Variable<String>(category);
    map['status'] = Variable<String>(status);
    map['current_value'] = Variable<double>(currentValue);
    map['valuation_date'] = Variable<String>(valuationDate);
    map['warranty_until'] = Variable<String>(warrantyUntil);
    map['last_used_date'] = Variable<String>(lastUsedDate);
    map['tags_json'] = Variable<String>(tagsJson);
    map['image'] = Variable<String>(image);
    map['sold_date'] = Variable<String>(soldDate);
    map['sale_price'] = Variable<double>(salePrice);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  AssetRowsCompanion toCompanion(bool nullToAbsent) {
    return AssetRowsCompanion(
      id: Value(id),
      name: Value(name),
      purchasePrice: Value(purchasePrice),
      purchaseDate: Value(purchaseDate),
      category: Value(category),
      status: Value(status),
      currentValue: Value(currentValue),
      valuationDate: Value(valuationDate),
      warrantyUntil: Value(warrantyUntil),
      lastUsedDate: Value(lastUsedDate),
      tagsJson: Value(tagsJson),
      image: Value(image),
      soldDate: Value(soldDate),
      salePrice: Value(salePrice),
      notes: Value(notes),
    );
  }

  factory AssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      purchaseDate: serializer.fromJson<String>(json['purchaseDate']),
      category: serializer.fromJson<String>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      valuationDate: serializer.fromJson<String>(json['valuationDate']),
      warrantyUntil: serializer.fromJson<String>(json['warrantyUntil']),
      lastUsedDate: serializer.fromJson<String>(json['lastUsedDate']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      image: serializer.fromJson<String>(json['image']),
      soldDate: serializer.fromJson<String>(json['soldDate']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'purchaseDate': serializer.toJson<String>(purchaseDate),
      'category': serializer.toJson<String>(category),
      'status': serializer.toJson<String>(status),
      'currentValue': serializer.toJson<double>(currentValue),
      'valuationDate': serializer.toJson<String>(valuationDate),
      'warrantyUntil': serializer.toJson<String>(warrantyUntil),
      'lastUsedDate': serializer.toJson<String>(lastUsedDate),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'image': serializer.toJson<String>(image),
      'soldDate': serializer.toJson<String>(soldDate),
      'salePrice': serializer.toJson<double>(salePrice),
      'notes': serializer.toJson<String>(notes),
    };
  }

  AssetRow copyWith({
    String? id,
    String? name,
    double? purchasePrice,
    String? purchaseDate,
    String? category,
    String? status,
    double? currentValue,
    String? valuationDate,
    String? warrantyUntil,
    String? lastUsedDate,
    String? tagsJson,
    String? image,
    String? soldDate,
    double? salePrice,
    String? notes,
  }) => AssetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    category: category ?? this.category,
    status: status ?? this.status,
    currentValue: currentValue ?? this.currentValue,
    valuationDate: valuationDate ?? this.valuationDate,
    warrantyUntil: warrantyUntil ?? this.warrantyUntil,
    lastUsedDate: lastUsedDate ?? this.lastUsedDate,
    tagsJson: tagsJson ?? this.tagsJson,
    image: image ?? this.image,
    soldDate: soldDate ?? this.soldDate,
    salePrice: salePrice ?? this.salePrice,
    notes: notes ?? this.notes,
  );
  AssetRow copyWithCompanion(AssetRowsCompanion data) {
    return AssetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      valuationDate: data.valuationDate.present
          ? data.valuationDate.value
          : this.valuationDate,
      warrantyUntil: data.warrantyUntil.present
          ? data.warrantyUntil.value
          : this.warrantyUntil,
      lastUsedDate: data.lastUsedDate.present
          ? data.lastUsedDate.value
          : this.lastUsedDate,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      image: data.image.present ? data.image.value : this.image,
      soldDate: data.soldDate.present ? data.soldDate.value : this.soldDate,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('currentValue: $currentValue, ')
          ..write('valuationDate: $valuationDate, ')
          ..write('warrantyUntil: $warrantyUntil, ')
          ..write('lastUsedDate: $lastUsedDate, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('image: $image, ')
          ..write('soldDate: $soldDate, ')
          ..write('salePrice: $salePrice, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    purchasePrice,
    purchaseDate,
    category,
    status,
    currentValue,
    valuationDate,
    warrantyUntil,
    lastUsedDate,
    tagsJson,
    image,
    soldDate,
    salePrice,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.purchasePrice == this.purchasePrice &&
          other.purchaseDate == this.purchaseDate &&
          other.category == this.category &&
          other.status == this.status &&
          other.currentValue == this.currentValue &&
          other.valuationDate == this.valuationDate &&
          other.warrantyUntil == this.warrantyUntil &&
          other.lastUsedDate == this.lastUsedDate &&
          other.tagsJson == this.tagsJson &&
          other.image == this.image &&
          other.soldDate == this.soldDate &&
          other.salePrice == this.salePrice &&
          other.notes == this.notes);
}

class AssetRowsCompanion extends UpdateCompanion<AssetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> purchasePrice;
  final Value<String> purchaseDate;
  final Value<String> category;
  final Value<String> status;
  final Value<double> currentValue;
  final Value<String> valuationDate;
  final Value<String> warrantyUntil;
  final Value<String> lastUsedDate;
  final Value<String> tagsJson;
  final Value<String> image;
  final Value<String> soldDate;
  final Value<double> salePrice;
  final Value<String> notes;
  final Value<int> rowid;
  const AssetRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.valuationDate = const Value.absent(),
    this.warrantyUntil = const Value.absent(),
    this.lastUsedDate = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.image = const Value.absent(),
    this.soldDate = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetRowsCompanion.insert({
    required String id,
    required String name,
    required double purchasePrice,
    required String purchaseDate,
    required String category,
    required String status,
    required double currentValue,
    this.valuationDate = const Value.absent(),
    this.warrantyUntil = const Value.absent(),
    this.lastUsedDate = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.image = const Value.absent(),
    this.soldDate = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       purchasePrice = Value(purchasePrice),
       purchaseDate = Value(purchaseDate),
       category = Value(category),
       status = Value(status),
       currentValue = Value(currentValue);
  static Insertable<AssetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? purchasePrice,
    Expression<String>? purchaseDate,
    Expression<String>? category,
    Expression<String>? status,
    Expression<double>? currentValue,
    Expression<String>? valuationDate,
    Expression<String>? warrantyUntil,
    Expression<String>? lastUsedDate,
    Expression<String>? tagsJson,
    Expression<String>? image,
    Expression<String>? soldDate,
    Expression<double>? salePrice,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (currentValue != null) 'current_value': currentValue,
      if (valuationDate != null) 'valuation_date': valuationDate,
      if (warrantyUntil != null) 'warranty_until': warrantyUntil,
      if (lastUsedDate != null) 'last_used_date': lastUsedDate,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (image != null) 'image': image,
      if (soldDate != null) 'sold_date': soldDate,
      if (salePrice != null) 'sale_price': salePrice,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? purchasePrice,
    Value<String>? purchaseDate,
    Value<String>? category,
    Value<String>? status,
    Value<double>? currentValue,
    Value<String>? valuationDate,
    Value<String>? warrantyUntil,
    Value<String>? lastUsedDate,
    Value<String>? tagsJson,
    Value<String>? image,
    Value<String>? soldDate,
    Value<double>? salePrice,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return AssetRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      category: category ?? this.category,
      status: status ?? this.status,
      currentValue: currentValue ?? this.currentValue,
      valuationDate: valuationDate ?? this.valuationDate,
      warrantyUntil: warrantyUntil ?? this.warrantyUntil,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      tagsJson: tagsJson ?? this.tagsJson,
      image: image ?? this.image,
      soldDate: soldDate ?? this.soldDate,
      salePrice: salePrice ?? this.salePrice,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(purchaseDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (valuationDate.present) {
      map['valuation_date'] = Variable<String>(valuationDate.value);
    }
    if (warrantyUntil.present) {
      map['warranty_until'] = Variable<String>(warrantyUntil.value);
    }
    if (lastUsedDate.present) {
      map['last_used_date'] = Variable<String>(lastUsedDate.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (soldDate.present) {
      map['sold_date'] = Variable<String>(soldDate.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('currentValue: $currentValue, ')
          ..write('valuationDate: $valuationDate, ')
          ..write('warrantyUntil: $warrantyUntil, ')
          ..write('lastUsedDate: $lastUsedDate, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('image: $image, ')
          ..write('soldDate: $soldDate, ')
          ..write('salePrice: $salePrice, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetEventRowsTable extends AssetEventRows
    with TableInfo<$AssetEventRowsTable, AssetEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetEventRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset_rows (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    type,
    date,
    amount,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_event_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $AssetEventRowsTable createAlias(String alias) {
    return $AssetEventRowsTable(attachedDatabase, alias);
  }
}

class AssetEventRow extends DataClass implements Insertable<AssetEventRow> {
  final String id;
  final String assetId;
  final String type;
  final String date;
  final double amount;
  final String notes;
  const AssetEventRow({
    required this.id,
    required this.assetId,
    required this.type,
    required this.date,
    required this.amount,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['type'] = Variable<String>(type);
    map['date'] = Variable<String>(date);
    map['amount'] = Variable<double>(amount);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  AssetEventRowsCompanion toCompanion(bool nullToAbsent) {
    return AssetEventRowsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      type: Value(type),
      date: Value(date),
      amount: Value(amount),
      notes: Value(notes),
    );
  }

  factory AssetEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetEventRow(
      id: serializer.fromJson<String>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      type: serializer.fromJson<String>(json['type']),
      date: serializer.fromJson<String>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assetId': serializer.toJson<String>(assetId),
      'type': serializer.toJson<String>(type),
      'date': serializer.toJson<String>(date),
      'amount': serializer.toJson<double>(amount),
      'notes': serializer.toJson<String>(notes),
    };
  }

  AssetEventRow copyWith({
    String? id,
    String? assetId,
    String? type,
    String? date,
    double? amount,
    String? notes,
  }) => AssetEventRow(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    type: type ?? this.type,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    notes: notes ?? this.notes,
  );
  AssetEventRow copyWithCompanion(AssetEventRowsCompanion data) {
    return AssetEventRow(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetEventRow(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, assetId, type, date, amount, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetEventRow &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.type == this.type &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.notes == this.notes);
}

class AssetEventRowsCompanion extends UpdateCompanion<AssetEventRow> {
  final Value<String> id;
  final Value<String> assetId;
  final Value<String> type;
  final Value<String> date;
  final Value<double> amount;
  final Value<String> notes;
  final Value<int> rowid;
  const AssetEventRowsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetEventRowsCompanion.insert({
    required String id,
    required String assetId,
    required String type,
    required String date,
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assetId = Value(assetId),
       type = Value(type),
       date = Value(date);
  static Insertable<AssetEventRow> custom({
    Expression<String>? id,
    Expression<String>? assetId,
    Expression<String>? type,
    Expression<String>? date,
    Expression<double>? amount,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetEventRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? assetId,
    Value<String>? type,
    Value<String>? date,
    Value<double>? amount,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return AssetEventRowsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetEventRowsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryRowsTable extends CategoryRows
    with TableInfo<$CategoryRowsTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [name, color, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoryRowsTable createAlias(String alias) {
    return $CategoryRowsTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String name;
  final String color;
  final int sortOrder;
  const CategoryRow({
    required this.name,
    required this.color,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoryRowsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRowsCompanion(
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({String? name, String? color, int? sortOrder}) =>
      CategoryRow(
        name: name ?? this.name,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CategoryRow copyWithCompanion(CategoryRowsCompanion data) {
    return CategoryRow(
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, color, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder);
}

class CategoryRowsCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> name;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoryRowsCompanion({
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRowsCompanion.insert({
    required String name,
    required String color,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       color = Value(color);
  static Insertable<CategoryRow> custom({
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRowsCompanion copyWith({
    Value<String>? name,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoryRowsCompanion(
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRowsCompanion(')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingRowsTable extends SettingRows
    with TableInfo<$SettingRowsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingRowsTable createAlias(String alias) {
    return $SettingRowsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingRowsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingRowsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingRowsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupRowsTable extends BackupRows
    with TableInfo<$BackupRowsTable, BackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, at, label, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $BackupRowsTable createAlias(String alias) {
    return $BackupRowsTable(attachedDatabase, alias);
  }
}

class BackupRow extends DataClass implements Insertable<BackupRow> {
  final String id;
  final String at;
  final String label;
  final String data;
  const BackupRow({
    required this.id,
    required this.at,
    required this.label,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<String>(at);
    map['label'] = Variable<String>(label);
    map['data'] = Variable<String>(data);
    return map;
  }

  BackupRowsCompanion toCompanion(bool nullToAbsent) {
    return BackupRowsCompanion(
      id: Value(id),
      at: Value(at),
      label: Value(label),
      data: Value(data),
    );
  }

  factory BackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRow(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<String>(json['at']),
      label: serializer.fromJson<String>(json['label']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<String>(at),
      'label': serializer.toJson<String>(label),
      'data': serializer.toJson<String>(data),
    };
  }

  BackupRow copyWith({String? id, String? at, String? label, String? data}) =>
      BackupRow(
        id: id ?? this.id,
        at: at ?? this.at,
        label: label ?? this.label,
        data: data ?? this.data,
      );
  BackupRow copyWithCompanion(BackupRowsCompanion data) {
    return BackupRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      label: data.label.present ? data.label.value : this.label,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('label: $label, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, label, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.label == this.label &&
          other.data == this.data);
}

class BackupRowsCompanion extends UpdateCompanion<BackupRow> {
  final Value<String> id;
  final Value<String> at;
  final Value<String> label;
  final Value<String> data;
  final Value<int> rowid;
  const BackupRowsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.label = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupRowsCompanion.insert({
    required String id,
    required String at,
    required String label,
    required String data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       label = Value(label),
       data = Value(data);
  static Insertable<BackupRow> custom({
    Expression<String>? id,
    Expression<String>? at,
    Expression<String>? label,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (label != null) 'label': label,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? at,
    Value<String>? label,
    Value<String>? data,
    Value<int>? rowid,
  }) {
    return BackupRowsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      label: label ?? this.label,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupRowsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('label: $label, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssetRowsTable assetRows = $AssetRowsTable(this);
  late final $AssetEventRowsTable assetEventRows = $AssetEventRowsTable(this);
  late final $CategoryRowsTable categoryRows = $CategoryRowsTable(this);
  late final $SettingRowsTable settingRows = $SettingRowsTable(this);
  late final $BackupRowsTable backupRows = $BackupRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    assetRows,
    assetEventRows,
    categoryRows,
    settingRows,
    backupRows,
  ];
}

typedef $$AssetRowsTableCreateCompanionBuilder =
    AssetRowsCompanion Function({
      required String id,
      required String name,
      required double purchasePrice,
      required String purchaseDate,
      required String category,
      required String status,
      required double currentValue,
      Value<String> valuationDate,
      Value<String> warrantyUntil,
      Value<String> lastUsedDate,
      Value<String> tagsJson,
      Value<String> image,
      Value<String> soldDate,
      Value<double> salePrice,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$AssetRowsTableUpdateCompanionBuilder =
    AssetRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> purchasePrice,
      Value<String> purchaseDate,
      Value<String> category,
      Value<String> status,
      Value<double> currentValue,
      Value<String> valuationDate,
      Value<String> warrantyUntil,
      Value<String> lastUsedDate,
      Value<String> tagsJson,
      Value<String> image,
      Value<String> soldDate,
      Value<double> salePrice,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$AssetRowsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetRowsTable, AssetRow> {
  $$AssetRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssetEventRowsTable, List<AssetEventRow>>
  _assetEventRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetEventRows,
    aliasName: $_aliasNameGenerator(db.assetRows.id, db.assetEventRows.assetId),
  );

  $$AssetEventRowsTableProcessedTableManager get assetEventRowsRefs {
    final manager = $$AssetEventRowsTableTableManager(
      $_db,
      $_db.assetEventRows,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assetEventRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetRowsTable> {
  $$AssetRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valuationDate => $composableBuilder(
    column: $table.valuationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warrantyUntil => $composableBuilder(
    column: $table.warrantyUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastUsedDate => $composableBuilder(
    column: $table.lastUsedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soldDate => $composableBuilder(
    column: $table.soldDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetEventRowsRefs(
    Expression<bool> Function($$AssetEventRowsTableFilterComposer f) f,
  ) {
    final $$AssetEventRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetEventRows,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetEventRowsTableFilterComposer(
            $db: $db,
            $table: $db.assetEventRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetRowsTable> {
  $$AssetRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valuationDate => $composableBuilder(
    column: $table.valuationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warrantyUntil => $composableBuilder(
    column: $table.warrantyUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastUsedDate => $composableBuilder(
    column: $table.lastUsedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soldDate => $composableBuilder(
    column: $table.soldDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetRowsTable> {
  $$AssetRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valuationDate => $composableBuilder(
    column: $table.valuationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warrantyUntil => $composableBuilder(
    column: $table.warrantyUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastUsedDate => $composableBuilder(
    column: $table.lastUsedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get soldDate =>
      $composableBuilder(column: $table.soldDate, builder: (column) => column);

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> assetEventRowsRefs<T extends Object>(
    Expression<T> Function($$AssetEventRowsTableAnnotationComposer a) f,
  ) {
    final $$AssetEventRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetEventRows,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetEventRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.assetEventRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetRowsTable,
          AssetRow,
          $$AssetRowsTableFilterComposer,
          $$AssetRowsTableOrderingComposer,
          $$AssetRowsTableAnnotationComposer,
          $$AssetRowsTableCreateCompanionBuilder,
          $$AssetRowsTableUpdateCompanionBuilder,
          (AssetRow, $$AssetRowsTableReferences),
          AssetRow,
          PrefetchHooks Function({bool assetEventRowsRefs})
        > {
  $$AssetRowsTableTableManager(_$AppDatabase db, $AssetRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<String> purchaseDate = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<String> valuationDate = const Value.absent(),
                Value<String> warrantyUntil = const Value.absent(),
                Value<String> lastUsedDate = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> soldDate = const Value.absent(),
                Value<double> salePrice = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetRowsCompanion(
                id: id,
                name: name,
                purchasePrice: purchasePrice,
                purchaseDate: purchaseDate,
                category: category,
                status: status,
                currentValue: currentValue,
                valuationDate: valuationDate,
                warrantyUntil: warrantyUntil,
                lastUsedDate: lastUsedDate,
                tagsJson: tagsJson,
                image: image,
                soldDate: soldDate,
                salePrice: salePrice,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double purchasePrice,
                required String purchaseDate,
                required String category,
                required String status,
                required double currentValue,
                Value<String> valuationDate = const Value.absent(),
                Value<String> warrantyUntil = const Value.absent(),
                Value<String> lastUsedDate = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> soldDate = const Value.absent(),
                Value<double> salePrice = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetRowsCompanion.insert(
                id: id,
                name: name,
                purchasePrice: purchasePrice,
                purchaseDate: purchaseDate,
                category: category,
                status: status,
                currentValue: currentValue,
                valuationDate: valuationDate,
                warrantyUntil: warrantyUntil,
                lastUsedDate: lastUsedDate,
                tagsJson: tagsJson,
                image: image,
                soldDate: soldDate,
                salePrice: salePrice,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssetRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetEventRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assetEventRowsRefs) db.assetEventRows,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assetEventRowsRefs)
                    await $_getPrefetchedData<
                      AssetRow,
                      $AssetRowsTable,
                      AssetEventRow
                    >(
                      currentTable: table,
                      referencedTable: $$AssetRowsTableReferences
                          ._assetEventRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AssetRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).assetEventRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.assetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssetRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetRowsTable,
      AssetRow,
      $$AssetRowsTableFilterComposer,
      $$AssetRowsTableOrderingComposer,
      $$AssetRowsTableAnnotationComposer,
      $$AssetRowsTableCreateCompanionBuilder,
      $$AssetRowsTableUpdateCompanionBuilder,
      (AssetRow, $$AssetRowsTableReferences),
      AssetRow,
      PrefetchHooks Function({bool assetEventRowsRefs})
    >;
typedef $$AssetEventRowsTableCreateCompanionBuilder =
    AssetEventRowsCompanion Function({
      required String id,
      required String assetId,
      required String type,
      required String date,
      Value<double> amount,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$AssetEventRowsTableUpdateCompanionBuilder =
    AssetEventRowsCompanion Function({
      Value<String> id,
      Value<String> assetId,
      Value<String> type,
      Value<String> date,
      Value<double> amount,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$AssetEventRowsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetEventRowsTable, AssetEventRow> {
  $$AssetEventRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetRowsTable _assetIdTable(_$AppDatabase db) =>
      db.assetRows.createAlias(
        $_aliasNameGenerator(db.assetEventRows.assetId, db.assetRows.id),
      );

  $$AssetRowsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetRowsTableTableManager(
      $_db,
      $_db.assetRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssetEventRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetEventRowsTable> {
  $$AssetEventRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetRowsTableFilterComposer get assetId {
    final $$AssetRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assetRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetRowsTableFilterComposer(
            $db: $db,
            $table: $db.assetRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetEventRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetEventRowsTable> {
  $$AssetEventRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetRowsTableOrderingComposer get assetId {
    final $$AssetRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assetRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetRowsTableOrderingComposer(
            $db: $db,
            $table: $db.assetRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetEventRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetEventRowsTable> {
  $$AssetEventRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$AssetRowsTableAnnotationComposer get assetId {
    final $$AssetRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assetRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.assetRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetEventRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetEventRowsTable,
          AssetEventRow,
          $$AssetEventRowsTableFilterComposer,
          $$AssetEventRowsTableOrderingComposer,
          $$AssetEventRowsTableAnnotationComposer,
          $$AssetEventRowsTableCreateCompanionBuilder,
          $$AssetEventRowsTableUpdateCompanionBuilder,
          (AssetEventRow, $$AssetEventRowsTableReferences),
          AssetEventRow,
          PrefetchHooks Function({bool assetId})
        > {
  $$AssetEventRowsTableTableManager(
    _$AppDatabase db,
    $AssetEventRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetEventRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetEventRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetEventRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetEventRowsCompanion(
                id: id,
                assetId: assetId,
                type: type,
                date: date,
                amount: amount,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assetId,
                required String type,
                required String date,
                Value<double> amount = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetEventRowsCompanion.insert(
                id: id,
                assetId: assetId,
                type: type,
                date: date,
                amount: amount,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssetEventRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable: $$AssetEventRowsTableReferences
                                    ._assetIdTable(db),
                                referencedColumn:
                                    $$AssetEventRowsTableReferences
                                        ._assetIdTable(db)
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

typedef $$AssetEventRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetEventRowsTable,
      AssetEventRow,
      $$AssetEventRowsTableFilterComposer,
      $$AssetEventRowsTableOrderingComposer,
      $$AssetEventRowsTableAnnotationComposer,
      $$AssetEventRowsTableCreateCompanionBuilder,
      $$AssetEventRowsTableUpdateCompanionBuilder,
      (AssetEventRow, $$AssetEventRowsTableReferences),
      AssetEventRow,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$CategoryRowsTableCreateCompanionBuilder =
    CategoryRowsCompanion Function({
      required String name,
      required String color,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoryRowsTableUpdateCompanionBuilder =
    CategoryRowsCompanion Function({
      Value<String> name,
      Value<String> color,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CategoryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoryRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRowsTable,
          CategoryRow,
          $$CategoryRowsTableFilterComposer,
          $$CategoryRowsTableOrderingComposer,
          $$CategoryRowsTableAnnotationComposer,
          $$CategoryRowsTableCreateCompanionBuilder,
          $$CategoryRowsTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoryRowsTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoryRowsTableTableManager(_$AppDatabase db, $CategoryRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRowsCompanion(
                name: name,
                color: color,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String color,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRowsCompanion.insert(
                name: name,
                color: color,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRowsTable,
      CategoryRow,
      $$CategoryRowsTableFilterComposer,
      $$CategoryRowsTableOrderingComposer,
      $$CategoryRowsTableAnnotationComposer,
      $$CategoryRowsTableCreateCompanionBuilder,
      $$CategoryRowsTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoryRowsTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$SettingRowsTableCreateCompanionBuilder =
    SettingRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingRowsTableUpdateCompanionBuilder =
    SettingRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingRowsTable,
          SettingRow,
          $$SettingRowsTableFilterComposer,
          $$SettingRowsTableOrderingComposer,
          $$SettingRowsTableAnnotationComposer,
          $$SettingRowsTableCreateCompanionBuilder,
          $$SettingRowsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingRowsTableTableManager(_$AppDatabase db, $SettingRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingRowsTable,
      SettingRow,
      $$SettingRowsTableFilterComposer,
      $$SettingRowsTableOrderingComposer,
      $$SettingRowsTableAnnotationComposer,
      $$SettingRowsTableCreateCompanionBuilder,
      $$SettingRowsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$BackupRowsTableCreateCompanionBuilder =
    BackupRowsCompanion Function({
      required String id,
      required String at,
      required String label,
      required String data,
      Value<int> rowid,
    });
typedef $$BackupRowsTableUpdateCompanionBuilder =
    BackupRowsCompanion Function({
      Value<String> id,
      Value<String> at,
      Value<String> label,
      Value<String> data,
      Value<int> rowid,
    });

class $$BackupRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupRowsTable> {
  $$BackupRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupRowsTable> {
  $$BackupRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupRowsTable> {
  $$BackupRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$BackupRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupRowsTable,
          BackupRow,
          $$BackupRowsTableFilterComposer,
          $$BackupRowsTableOrderingComposer,
          $$BackupRowsTableAnnotationComposer,
          $$BackupRowsTableCreateCompanionBuilder,
          $$BackupRowsTableUpdateCompanionBuilder,
          (
            BackupRow,
            BaseReferences<_$AppDatabase, $BackupRowsTable, BackupRow>,
          ),
          BackupRow,
          PrefetchHooks Function()
        > {
  $$BackupRowsTableTableManager(_$AppDatabase db, $BackupRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupRowsCompanion(
                id: id,
                at: at,
                label: label,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String at,
                required String label,
                required String data,
                Value<int> rowid = const Value.absent(),
              }) => BackupRowsCompanion.insert(
                id: id,
                at: at,
                label: label,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupRowsTable,
      BackupRow,
      $$BackupRowsTableFilterComposer,
      $$BackupRowsTableOrderingComposer,
      $$BackupRowsTableAnnotationComposer,
      $$BackupRowsTableCreateCompanionBuilder,
      $$BackupRowsTableUpdateCompanionBuilder,
      (BackupRow, BaseReferences<_$AppDatabase, $BackupRowsTable, BackupRow>),
      BackupRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssetRowsTableTableManager get assetRows =>
      $$AssetRowsTableTableManager(_db, _db.assetRows);
  $$AssetEventRowsTableTableManager get assetEventRows =>
      $$AssetEventRowsTableTableManager(_db, _db.assetEventRows);
  $$CategoryRowsTableTableManager get categoryRows =>
      $$CategoryRowsTableTableManager(_db, _db.categoryRows);
  $$SettingRowsTableTableManager get settingRows =>
      $$SettingRowsTableTableManager(_db, _db.settingRows);
  $$BackupRowsTableTableManager get backupRows =>
      $$BackupRowsTableTableManager(_db, _db.backupRows);
}
