// vehicle_type_model.dart
class VehicleType {
  VehicleType({
    this.id,
    this.type,
    this.name,
    this.seatingCapacity,
    this.startingPrice,
    this.ratePerKm,
    this.image,
  });

  int? id;
  String? type;
  String? name;
  int? seatingCapacity;
  double? startingPrice;
  double? ratePerKm;
  String? image;

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] as int?,
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      seatingCapacity: json['seating_capacity'] as int?,
      startingPrice: double.tryParse(json['starting_price'].toString()) ?? 0.0,
      ratePerKm: double.tryParse(json['rate_per_km'].toString()) ?? 0.0,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'seating_capacity': seatingCapacity,
    'starting_price': startingPrice,
    'rate_per_km': ratePerKm,
    'image': image,
  };
}
