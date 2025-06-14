import 'dart:collection';

/// A simple in-memory cache manager with LRU eviction policy
class CacheManager<T> {
  final int maxItems;
  final Map<String, _CacheEntry<T>> _cache;
  final LinkedList<_CacheEntry<T>> _lruList;

  /// Creates a cache manager with the given maximum number of items
  CacheManager({this.maxItems = 100})
    : _cache = {},
      _lruList = LinkedList<_CacheEntry<T>>();

  /// Adds or updates an item in the cache
  void setItem(String key, T value) {
    // Remove existing entry if present
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      entry.unlink();
      _cache.remove(key);
    }

    // Evict least recently used item if cache is full
    if (_cache.length >= maxItems && _lruList.isNotEmpty) {
      final leastUsed = _lruList.last;
      _cache.remove(leastUsed.key);
      leastUsed.unlink();
    }

    // Add new entry
    final entry = _CacheEntry<T>(key, value);
    _cache[key] = entry;
    _lruList.addFirst(entry);
  }

  /// Retrieves an item from the cache
  T? getItem(String key) {
    final entry = _cache[key];
    if (entry == null) {
      return null;
    }

    // Move to front of LRU list
    entry.unlink();
    _lruList.addFirst(entry);

    return entry.value;
  }

  /// Checks if the cache contains an item with the given key
  bool containsKey(String key) => _cache.containsKey(key);

  /// Removes an item from the cache
  void removeItem(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      entry.unlink();
    }
  }

  /// Clears all items from the cache
  void clear() {
    _cache.clear();
    _lruList.clear();
  }

  /// Returns the number of items in the cache
  int get length => _cache.length;

  /// Returns whether the cache is empty
  bool get isEmpty => _cache.isEmpty;

  /// Returns whether the cache is not empty
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Returns all keys in the cache
  Iterable<String> get keys => _cache.keys;

  /// Returns all values in the cache, ordered by most recently used first
  Iterable<T> get values => _lruList.map((entry) => entry.value);
}

/// Internal cache entry with linked list support
base class _CacheEntry<T> extends LinkedListEntry<_CacheEntry<T>> {
  final String key;
  final T value;

  _CacheEntry(this.key, this.value);
}
