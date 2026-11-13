import 'dart:async';

/// Owns a monotonic countdown independently from any UI lifecycle.
class SleepTimerService {
  SleepTimerService({
    required this.onExpired,
    this.tickInterval = const Duration(seconds: 1),
  }) {
    if (tickInterval <= Duration.zero) {
      throw ArgumentError.value(tickInterval, 'tickInterval');
    }
  }

  final Future<void> Function() onExpired;
  final Duration tickInterval;
  final StreamController<Duration?> _remainingController =
      StreamController<Duration?>.broadcast();

  Timer? _timer;
  Stopwatch? _stopwatch;
  Duration _targetDuration = Duration.zero;
  Duration? _remaining;
  bool _disposed = false;
  bool _expirationDispatched = false;

  bool get isActive => _timer?.isActive ?? false;

  Duration? get remainingTime {
    final stopwatch = _stopwatch;
    if (stopwatch == null || !isActive) return _remaining;
    final value = _targetDuration - stopwatch.elapsed;
    return value > Duration.zero ? value : Duration.zero;
  }

  Stream<Duration?> get remainingTimeStream => _remainingController.stream;

  void start(Duration duration) {
    _ensureNotDisposed();
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'Must be positive.');
    }

    _cancelInternal();
    _targetDuration = duration;
    _remaining = duration;
    _expirationDispatched = false;
    _stopwatch = Stopwatch()..start();
    _publish(duration);
    _timer = Timer.periodic(tickInterval, (_) => _handleTick());
  }

  void cancel() {
    _ensureNotDisposed();
    _cancelInternal();
    _remaining = null;
    _publish(null);
  }

  void _handleTick() {
    final stopwatch = _stopwatch;
    if (stopwatch == null) return;

    final remaining = _targetDuration - stopwatch.elapsed;
    if (remaining <= Duration.zero) {
      _timer?.cancel();
      _timer = null;
      stopwatch.stop();
      _stopwatch = null;
      _remaining = Duration.zero;
      _publish(Duration.zero);

      if (!_expirationDispatched) {
        _expirationDispatched = true;
        unawaited(onExpired());
      }
      return;
    }

    _remaining = remaining;
    _publish(remaining);
  }

  void _cancelInternal() {
    _timer?.cancel();
    _timer = null;
    _stopwatch?.stop();
    _stopwatch = null;
    _targetDuration = Duration.zero;
  }

  void _publish(Duration? value) {
    if (!_remainingController.isClosed) {
      _remainingController.add(value);
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SleepTimerService has been disposed.');
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _cancelInternal();
    await _remainingController.close();
  }
}
