class ParkingPlace {
  final String id;
  final String name;
  final String address;
  final int totalSlots;
  final int availableSlots;
  final double latitude;  // Add this
  final double longitude; // Add this
  

  ParkingPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.latitude,   // Add this
    required this.longitude,  // Add this
  });

  factory ParkingPlace.fromJson(Map<String, dynamic> json) {
    return ParkingPlace(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      totalSlots: json['total_slots'],
      availableSlots: json['available_slots'],
      latitude: json['latitude'],    // Add this
      longitude: json['longitude'], 
    );
  }
}