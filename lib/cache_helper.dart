import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> putBool({
    required String key,
    required bool value,
  }) async {
    return await sharedPreferences!.setBool(key, value);
  }

  static dynamic getData({
    required String key,
  }) {
    final storedValue = sharedPreferences?.get(key);
    return storedValue != null;
  }

  static dynamic getDataMessage({
    required String key,
  }) {
    final storedValue = sharedPreferences?.get(key);
    return storedValue ?? "null";
  }

  static dynamic getActualData({
    required String key,
  }) {
    return sharedPreferences?.get(key);
  }

  static Future<bool> saveDate({
    required String key,
    dynamic value,
  }) async {
    final type = value.runtimeType;
    if (type == String) {
      return await sharedPreferences!.setString(key, value as String);
    }
    if (type == int) {
      return await sharedPreferences!.setInt(key, value as int);
    }
    if (type == bool) {
      return await sharedPreferences!.setBool(key, value as bool);
    }

    if (type == double) {
      return await sharedPreferences!.setDouble(key, value as double);
    }
    throw ArgumentError(
        'Unsupported type ${type.toString()} for saving in SharedPreferences');
  }

  static Future<bool> setStringList({
    required String key,
    dynamic value,
  }) async {
    return await sharedPreferences!.setStringList(key, value);
  }

  static Future<List<String>?> getStringList({
    required String key,
    dynamic value,
  }) async {
    return sharedPreferences!.getStringList(key);
  }

  static Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPreferences!.remove(key);
  }
}
