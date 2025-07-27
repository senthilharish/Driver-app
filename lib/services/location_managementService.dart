import 'dart:async';
import 'package:driver_application/data/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationManagementService extends ChangeNotifier {
  Timer? _locationTimer;
  Position? _currentPosition;
  bool _isTracking = false;
  String? _currentBusNumber;
  String? _currentDriverId;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get currentBusNumber => _currentBusNumber;

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return true;
  }

  Future<void> startTracking({
    required String busNumber,
    required String driverId,
  }) async {
    try {
      await checkLocationPermission();

      _currentBusNumber = busNumber;
      _currentDriverId = driverId;
      _isTracking = true;
      notifyListeners();

      // Get initial location
      await _updateLocation();

      _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _updateLocation();
      });
    } catch (e) {
      _isTracking = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      notifyListeners();

      if (_currentBusNumber != null && _currentDriverId != null) {
        await FirebaseService.updateBusLocation(
          busNumber: _currentBusNumber!,
          location: GeoPoint(position.latitude, position.longitude),
          driverId: _currentDriverId!,
        );
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> stopTracking() async {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;

    if (_currentBusNumber != null && _currentDriverId != null) {
      try {
        await FirebaseService.setBusInactive(
          busNumber: _currentBusNumber!,
          driverId: _currentDriverId!,
        );
      } catch (e) {
        debugPrint('Error setting bus inactive: $e');
      }
    }

    _currentBusNumber = null;
    _currentDriverId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}