import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String busesCollection = 'buses';

  // Update bus location
  static Future<void> updateBusLocation({
    required String busNumber,
    required GeoPoint location,
    required String driverId,
  }) async {
    try {
      await _firestore
          .collection(busesCollection)
          .doc(busNumber)
          .set({
        'busNumber': busNumber,
        'location': location,
        'timestamp': Timestamp.now(),
        'driverId': driverId,
        'isActive': true,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update bus location: $e');
    }
  }

  // Set bus as inactive
  static Future<void> setBusInactive({
    required String busNumber,
    required String driverId,
  }) async {
    try {
      await _firestore
          .collection(busesCollection)
          .doc(busNumber)
          .update({
        'isActive': false,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to set bus inactive: $e');
    }
  }

  // Get bus data
  static Future<BusModel?> getBusData(String busNumber) async {
    try {
      final doc = await _firestore
          .collection(busesCollection)
          .doc(busNumber)
          .get();
      
      if (doc.exists) {
        return BusModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get bus data: $e');
    }
  }

  // Stream bus location updates
  static Stream<BusModel?> streamBusData(String busNumber) {
    return _firestore
        .collection(busesCollection)
        .doc(busNumber)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return BusModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}