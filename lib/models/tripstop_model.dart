class TripStop {
  int? tripBookingId;
  String? address;
  double? latitude;
  double? longitude;
  int? stopOrder;

  TripStop({
    this.tripBookingId,
    this.address,
    this.latitude,
    this.longitude,
    this.stopOrder,
  });

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      tripBookingId: json['trip_booking_id'] != null ? int.tryParse(json['trip_booking_id'].toString()) : null,
      address: json['address']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      stopOrder: json['stop_order'] != null ? int.tryParse(json['stop_order'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_booking_id': tripBookingId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'stop_order': stopOrder,
    };
  }
}
