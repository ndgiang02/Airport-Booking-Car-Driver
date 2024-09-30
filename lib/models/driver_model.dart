// driver_model.dart
import 'vehicle_model.dart';

class DriverModel {
  DriverModel({
    this.id,
    this.userId,
    this.licenseNo,
    this.latitude,
    this.longitude,
    this.rating,
    this.available,
    this.vehicle,
  });

  int? id;
  int? userId;
  String? licenseNo;
  double? rating;
  bool? available;
  Vehicle? vehicle;
  double? latitude;
  double? longitude;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      licenseNo: json['license_no']?.toString(),
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      available: json['available'] == 1,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'license_no': licenseNo,
    'rating': rating,
    'available': available == true ? 1 : 0,
    'vehicle': vehicle?.toJson(),
    'latitude': latitude,
    'longitude': longitude,
  };
}
