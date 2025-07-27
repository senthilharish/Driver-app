import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String busNumber;
  final GeoPoint? location;
  final DateTime? timestamp;
  final String? driverId;
  final bool isActive;

  BusModel({
    required this.busNumber,
    this.location,
    this.timestamp,
    this.driverId,
    this.isActive = false,
  });

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      busNumber: map['busNumber'] ?? '',
      location: map['location'] as GeoPoint?,
      timestamp: map['timestamp']?.toDate(),
      driverId: map['driverId'],
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busNumber': busNumber,
      'location': location,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'driverId': driverId,
      'isActive': isActive,
    };
  }

  BusModel copyWith({
    String? busNumber,
    GeoPoint? location,
    DateTime? timestamp,
    String? driverId,
    bool? isActive,
  }) {
    return BusModel(
      busNumber: busNumber ?? this.busNumber,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      driverId: driverId ?? this.driverId,
      isActive: isActive ?? this.isActive,
    );
  }
}