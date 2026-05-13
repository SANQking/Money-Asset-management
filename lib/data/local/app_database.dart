import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class AssetRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get purchasePrice => real()();
  TextColumn get purchaseDate => text()();
  TextColumn get category => text()();
  TextColumn get status => text()();
  RealColumn get currentValue => real()();
  TextColumn get valuationDate => text().withDefault(const Constant(''))();
  TextColumn get warrantyUntil => text().withDefault(const Constant(''))();
  TextColumn get lastUsedDate => text().withDefault(const Constant(''))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get image => text().withDefault(const Constant(''))();
  TextColumn get soldDate => text().withDefault(const Constant(''))();
  RealColumn get salePrice => real().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AssetEventRows extends Table {
  TextColumn get id => text()();
  TextColumn get assetId => text().references(AssetRows, #id)();
  TextColumn get type => text()();
  TextColumn get date => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CategoryRows extends Table {
  TextColumn get name => text()();
  TextColumn get color => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

class SettingRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class BackupRows extends Table {
  TextColumn get id => text()();
  TextColumn get at => text()();
  TextColumn get label => text()();
  TextColumn get data => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [AssetRows, AssetEventRows, CategoryRows, SettingRows, BackupRows],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'grzcgl.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
