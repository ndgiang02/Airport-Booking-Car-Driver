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
      tripBookingId: json['id'],
      address: json['stop_address']?.toString(),
      latitude: json['stop_lat'] != null ? double.tryParse(json['stop_lat'].toString()) : null,
      longitude: json['stop_lng'] != null ? double.tryParse(json['stop_lng'].toString()) : null,
      stopOrder: json['stop_order'],
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
