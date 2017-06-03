import 'dart:math';

class RefreshableSet {
  /// Used to determine if the [_available] set should be repopulated
  /// with the contents of [_taken] after [_available] becomes empty.
  bool refreshingEnabled;

  /// Used to determine when to refresh the set.
  int _refreshAfter;
  int _currentRefreshCount = 0;

  /// The set of items available for the user to take from.
  Set<dynamic> _available = new Set();

  /// The set of items already taken from [_available].
  Set<dynamic> _taken = new Set();

  RefreshableSet(this.refreshingEnabled, [this._refreshAfter]);

  /// Adds an item to the [_available] data set.
  /// An item can only appear once in the union of [_available] and [_taken].
  ///
  /// Returns true if an item was added to the data set, false otherwise.
  bool add(dynamic item) {
    return _taken.contains(item) ? false : _available.add(item);
  }

  /// Removes a random item from the [_available] set.
  /// The item is placed in the [_taken] set, and then returned to the user.
  /// If [refreshingEnabled] is enabled, the [_available] set will be refreshed
  /// with the contents of the [_taken] set before any removal takes place.
  ///
  /// Returns an item from the data set, null if none exist.
  dynamic get take {
    _attemptToRefresh();

    if (_available.isEmpty) return null;

    Random rng = new Random();

    var item = _available.toList()[rng.nextInt(_available.length)];

    _available.remove(item);
    _taken.add(item);

    if (refreshingEnabled) _currentRefreshCount++;

    return item;
  }

  /// Returns the union of [_available] and [_taken].
  Set<dynamic> get all => _available.union(_taken);

  /// Moves all items from the [_taken] set to the [_available] set.
  void _attemptToRefresh() {
    if (!_shouldRefresh()) return;
    _available.addAll(_taken);
    _taken.clear();
    _currentRefreshCount = 0;
  }

  /// Determines if the data set should refresh or not.
  bool _shouldRefresh() {
    return refreshingEnabled ? _currentRefreshCount >= _refreshAfter : false;
  }
}

/// Used for testing purposes only.
class ExposedRefreshableSet extends RefreshableSet {
  ExposedRefreshableSet(bool refreshingEnabled, [int refreshAfter])
      : super(refreshingEnabled, refreshAfter);

  int get refreshAfter => _refreshAfter;
  int get currentRefreshCount => _currentRefreshCount;
  Set<dynamic> get available => _available;
  Set<dynamic> get taken => _taken;
  bool get shouldRefresh => _shouldRefresh();
}
