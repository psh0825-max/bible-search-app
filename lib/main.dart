import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 웹에서는 sqflite 네이티브 구현이 없으므로 WASM(IndexedDB) 팩토리 사용.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const ProviderScope(child: BibleSearchApp()));
}
