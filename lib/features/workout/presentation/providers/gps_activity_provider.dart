import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Outdoor Activity Types
enum ActivityType { walking, cycling, running }

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.walking: return 'Walking';
      case ActivityType.cycling: return 'Cycling';
      case ActivityType.running: return 'Running';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityType.walking: return '🚶';
      case ActivityType.cycling: return '🚴';
      case ActivityType.running: return '🏃';
    }
  }

  /// MET (Metabolic Equivalent of Task) for calorie calculation
  double get met {
    switch (this) {
      case ActivityType.walking: return 3.5;
      case ActivityType.cycling: return 7.5;
      case ActivityType.running: return 9.8;
    }
  }
}

/// Live GPS Activity State
class GpsActivityState {
  final bool isTracking;
  final bool isPaused;
  final ActivityType activityType;
  final Duration elapsed;
  final double distanceKm;
  final double speedKmh;
  final double caloriesBurned;
  final bool hasPermission;
  final String? error;
  final List<Position> positions;

  const GpsActivityState({
    this.isTracking = false,
    this.isPaused = false,
    this.activityType = ActivityType.walking,
    this.elapsed = Duration.zero,
    this.distanceKm = 0.0,
    this.speedKmh = 0.0,
    this.caloriesBurned = 0.0,
    this.hasPermission = false,
    this.error,
    this.positions = const [],
  });

  GpsActivityState copyWith({
    bool? isTracking,
    bool? isPaused,
    ActivityType? activityType,
    Duration? elapsed,
    double? distanceKm,
    double? speedKmh,
    double? caloriesBurned,
    bool? hasPermission,
    String? error,
    List<Position>? positions,
  }) {
    return GpsActivityState(
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      activityType: activityType ?? this.activityType,
      elapsed: elapsed ?? this.elapsed,
      distanceKm: distanceKm ?? this.distanceKm,
      speedKmh: speedKmh ?? this.speedKmh,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
      positions: positions ?? this.positions,
    );
  }
}

class GpsActivityNotifier extends Notifier<GpsActivityState> {
  Timer? _elapsedTimer;
  StreamSubscription<Position>? _positionSub;
  // Default weight 70kg if profile not available
  final double _weightKg = 70.0;

  @override
  GpsActivityState build() => const GpsActivityState();

  Future<void> requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      state = state.copyWith(hasPermission: true);
    } else {
      state = state.copyWith(
        hasPermission: false,
        error: 'Location permission is required to track outdoor activities.',
      );
    }
  }

  void selectActivity(ActivityType type) {
    if (!state.isTracking) {
      state = state.copyWith(activityType: type);
    }
  }

  Future<void> startTracking() async {
    // Ensure permission before starting
    final status = await Permission.location.status;
    if (!status.isGranted) {
      await requestPermission();
      if (!state.hasPermission) return;
    }

    state = state.copyWith(
      isTracking: true,
      isPaused: false,
      elapsed: Duration.zero,
      distanceKm: 0.0,
      speedKmh: 0.0,
      caloriesBurned: 0.0,
      positions: [],
      error: null,
    );

    // Start elapsed timer
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPaused) {
        state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
        _recalculateCalories();
      }
    });

    // Start GPS position stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // meters
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position pos) {
        if (state.isPaused) return;
        final List<Position> updated = List.from(state.positions)..add(pos);
        final double distKm = _calculateTotalDistance(updated);
        final double speed = pos.speed >= 0 ? (pos.speed * 3.6) : 0.0; // m/s → km/h

        state = state.copyWith(
          positions: updated,
          distanceKm: distKm,
          speedKmh: double.parse(speed.toStringAsFixed(1)),
        );
      },
      onError: (e) {
        state = state.copyWith(error: 'GPS signal lost. Please ensure location is enabled.');
      },
    );
  }

  void pauseTracking() {
    state = state.copyWith(isPaused: true);
  }

  void resumeTracking() {
    state = state.copyWith(isPaused: false);
  }

  Future<void> finishTracking() async {
    _elapsedTimer?.cancel();
    await _positionSub?.cancel();
    // Keep final stats visible but mark as stopped
    state = state.copyWith(isTracking: false, isPaused: false);
  }

  void resetActivity() {
    _elapsedTimer?.cancel();
    _positionSub?.cancel();
    state = const GpsActivityState(hasPermission: true);
  }

  void _recalculateCalories() {
    // MET formula: Calories = MET × weight(kg) × time(hours)
    final hours = state.elapsed.inSeconds / 3600.0;
    final cal = state.activityType.met * _weightKg * hours;
    state = state.copyWith(caloriesBurned: double.parse(cal.toStringAsFixed(1)));
  }

  double _calculateTotalDistance(List<Position> positions) {
    if (positions.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < positions.length; i++) {
      total += Geolocator.distanceBetween(
        positions[i - 1].latitude,
        positions[i - 1].longitude,
        positions[i].latitude,
        positions[i].longitude,
      );
    }
    return double.parse((total / 1000).toStringAsFixed(2)); // meters → km
  }

  String get formattedElapsed {
    final s = state.elapsed.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get formattedPace {
    if (state.distanceKm == 0 || state.elapsed.inMinutes == 0) return '-- min/km';
    final minPerKm = state.elapsed.inMinutes / state.distanceKm;
    final min = minPerKm.floor();
    final sec = ((minPerKm - min) * 60).round();
    return '${min}:${sec.toString().padLeft(2, '0')} min/km';
  }
}

final gpsActivityProvider =
    NotifierProvider<GpsActivityNotifier, GpsActivityState>(
  GpsActivityNotifier.new,
);
