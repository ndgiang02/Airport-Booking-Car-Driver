// driver_model.dart
import 'vehicle_model.dart';

class DriverModel {
  DriverModel({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  DriverData? data;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      data: json['data'] != null ? DriverData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}


class DriverData {
  DriverData({
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

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
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
