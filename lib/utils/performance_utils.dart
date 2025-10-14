import 'dart:async';
import 'package:flutter/material.dart';

class PerformanceUtils {
  static final Map<String, Timer> _debounceTimers = {};
  static final Map<String, DateTime> _lastCallTimes = {};

  /// Debounce function calls to prevent excessive execution
  static void debounce(String key, VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  /// Throttle function calls to limit execution frequency
  static bool throttle(String key, VoidCallback callback, {Duration interval = const Duration(milliseconds: 1000)}) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[key];
    
    if (lastCall == null || now.difference(lastCall) >= interval) {
      _lastCallTimes[key] = now;
      callback();
      return true;
    }
    return false;
  }

  /// Clear all debounce timers
  static void clearDebounceTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Clear throttle cache
  static void clearThrottleCache() {
    _lastCallTimes.clear();
  }

  /// Clean up all performance utilities
  static void dispose() {
    clearDebounceTimers();
    clearThrottleCache();
  }
}

class LazyLoader {
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final double threshold;
  bool _isLoading = false;

  LazyLoader({
    required this.scrollController,
    required this.onLoadMore,
    this.threshold = 100.0,
  }) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoading) return;
    
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - threshold) {
      _isLoading = true;
      onLoadMore();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}

class ImageCacheManager {
  static final Map<String, ImageProvider> _cache = {};
  static const int maxCacheSize = 50;

  static ImageProvider getCachedImage(String key, ImageProvider Function() loader) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    if (_cache.length >= maxCacheSize) {
      // Remove oldest entry
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }

    final image = loader();
    _cache[key] = image;
    return image;
  }

  static void clearCache() {
    _cache.clear();
  }

  static void removeFromCache(String key) {
    _cache.remove(key);
  }
}

class MemoryOptimizer {
  static Timer? _gcTimer;
  static const Duration gcInterval = Duration(minutes: 5);

  static void startPeriodicGC() {
    _gcTimer?.cancel();
    _gcTimer = Timer.periodic(gcInterval, (_) {
      _forceGC();
    });
  }

  static void stopPeriodicGC() {
    _gcTimer?.cancel();
    _gcTimer = null;
  }

  static void _forceGC() {
    // Force garbage collection
    // Note: This is a simplified approach
    // In production, you might want to use more sophisticated memory management
    ImageCacheManager.clearCache();
    PerformanceUtils.clearDebounceTimers();
  }
}

class NetworkOptimizer {
  static final Map<String, DateTime> _requestCache = {};
  static const Duration cacheTimeout = Duration(minutes: 5);

  static bool shouldMakeRequest(String endpoint) {
    final lastRequest = _requestCache[endpoint];
    if (lastRequest == null) return true;
    
    return DateTime.now().difference(lastRequest) > cacheTimeout;
  }

  static void markRequest(String endpoint) {
    _requestCache[endpoint] = DateTime.now();
  }

  static void clearCache() {
    _requestCache.clear();
  }

  static void removeFromCache(String endpoint) {
    _requestCache.remove(endpoint);
  }
}

class WidgetOptimizer {
  static Widget buildOptimizedList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? scrollController,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance optimizations
      cacheExtent: 250.0, // Cache 250 pixels worth of widgets
      addAutomaticKeepAlives: false, // Don't keep widgets alive when not visible
      addRepaintBoundaries: true, // Add repaint boundaries for better performance
      addSemanticIndexes: false, // Disable semantic indexes for better performance
    );
  }

  static Widget buildOptimizedGrid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    ScrollController? scrollController,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        crossAxisSpacing: crossAxisSpacing ?? 0.0,
        mainAxisSpacing: mainAxisSpacing ?? 0.0,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance optimizations
      cacheExtent: 250.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }
}
