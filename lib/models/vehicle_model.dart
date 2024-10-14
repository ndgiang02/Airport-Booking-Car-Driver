// vehicle_model.dart
import 'package:driverapp/models/vehicletype_model.dart';

class VehicleModel {
  VehicleModel({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  Vehicle? data;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      data: json['data'] != null ? Vehicle.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class Vehicle {
  Vehicle({
    this.driverId,
    this.vehicleTypeId,
    this.brand,
    this.model,
    this.color,
    this.licensePlate,
    this.vehicleType,
  });

  int? driverId;
  int? vehicleTypeId;
  String? brand;
  String? model;
  String? color;
  String? licensePlate;
  VehicleType? vehicleType;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      driverId: json['driver_id'] as int?,
      vehicleTypeId: json['vehicle_type_id'] as int?,
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      color: json['color']?.toString(),
      licensePlate: json['license_plate']?.toString(),
      vehicleType: json['vehicle_type'] != null ? VehicleType.fromJson(json['vehicle_type']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'driver_id': driverId,
    'vehicle_type_id': vehicleTypeId,
    'brand': brand,
    'model': model,
    'color': color,
    'license_plate': licensePlate,
    'vehicle_type': vehicleType?.toJson(),
  };
}
