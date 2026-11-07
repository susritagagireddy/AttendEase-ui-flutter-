import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveJson(String key, Object data) async {
  final p = await SharedPreferences.getInstance();
  await p.setString(key, jsonEncode(data));
}

Future<dynamic> loadJson(String key) async {
  final p = await SharedPreferences.getInstance();
  final raw = p.getString(key);
  return raw == null ? null : jsonDecode(raw);
}
