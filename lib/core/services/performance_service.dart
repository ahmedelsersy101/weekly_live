import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  Timer? _searchDebounceTimer;

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  static const Duration _cacheDuration = Duration(minutes: 5);

  void debounceSearch(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(duration, callback);
  }

  T? getCachedResult<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  void cacheResult<T>(String key, T result) {
    _cache[key] = result;
    _cacheTimestamps[key] = DateTime.now();
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  Future<T> executeInBackground<T>(T Function() operation) async {
    return await compute(_executeOperation, operation);
  }

  static T _executeOperation<T>(T Function() operation) {
    return operation();
  }

  bool shouldThrottle(
    String key, {
    Duration throttleDuration = const Duration(milliseconds: 100),
  }) {
    final lastExecution = _cacheTimestamps[key];
    if (lastExecution == null) return false;

    return DateTime.now().difference(lastExecution) < throttleDuration;
  }

  void dispose() {
    _searchDebounceTimer?.cancel();
    clearCache();
  }
}
