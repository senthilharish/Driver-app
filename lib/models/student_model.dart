import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String name;
  final num rollNumber;
  final String busNumber;
  final GeoPoint stopLocation;
  final String fcmToken;

  StudentModel({
    required this.uid,
    required this.name,
    required this.rollNumber,
    required this.busNumber,
    required this.stopLocation,
    required this.fcmToken,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'],
      busNumber: map['busNumber'] ?? '',
      stopLocation: map['stopLocation'] ?? const GeoPoint(0, 0),
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rollNumber':rollNumber,
      'busNumber': busNumber,
      'stopLocation': stopLocation,
      'fcmToken': fcmToken,
    };
  }

  StudentModel copyWith({
    String? name,
    num? rollNumber,
    String? busNumber,
    GeoPoint? stopLocation,
    String? fcmToken,
  }) {
    return StudentModel(
      uid: uid,
      name: name ?? this.name,
      rollNumber: rollNumber?? this.rollNumber,
      busNumber: busNumber ?? this.busNumber,
      stopLocation: stopLocation ?? this.stopLocation,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}