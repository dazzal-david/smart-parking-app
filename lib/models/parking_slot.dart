class ParkingSlot {
  final String id;
  final String placeId;
  final String slotNumber;
  final bool isOccupied;

  ParkingSlot({
    required this.id,
    required this.placeId,
    required this.slotNumber,
    required this.isOccupied,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'],
      placeId: json['place_id'],
      slotNumber: json['slot_number'],
      isOccupied: json['is_occupied'],
    );
  }
}