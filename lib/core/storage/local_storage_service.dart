import 'dart:convert';

import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Save string data
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  // Get string data
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve data: $e');
    }
  }

  // Save boolean data
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  // Get boolean data
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve data: $e');
    }
  }

  // Save int data
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  // Get int data
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve data: $e');
    }
  }

  // Save double data
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  // Get double data
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve data: $e');
    }
  }

  // Save list of strings data
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  // Get list of strings data
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve data: $e');
    }
  }

  // Save object data (converts to JSON string)
  Future<bool> setObject(String key, Object value) async {
    try {
      final String jsonString = json.encode(value);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to save data: $e');
    }
  }

  // Get object data (converts from JSON string)
  dynamic getObject(String key) {
    try {
      final String? jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve data: $e');
    }
  }

  // Check if key exists
  bool hasKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      throw CacheException(message: 'Failed to check key: $e');
    }
  }

  // Remove data by key
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      throw CacheException(message: 'Failed to remove data: $e');
    }
  }

  // Clear all data
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear data: $e');
    }
  }
}
