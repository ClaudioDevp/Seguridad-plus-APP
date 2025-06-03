class LocationModel {
  final double lat;
  final double lng;

  LocationModel({required this.lat, required this.lng});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(lat: json["lat"], lng: json["lng"]);
  }

  Map<String, dynamic> toJson() {
    return {"lat": lat, "lng": lng};
  }
}
