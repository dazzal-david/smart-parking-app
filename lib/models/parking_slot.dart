class ParkingSlot {
  final String id;
  final String placeId;
  final String slotNumber;
  final bool isOccupied;
  final String qrCode;

  ParkingSlot({
    required this.id,
    required this.placeId,
    required this.slotNumber,
    required this.isOccupied,
    required this.qrCode,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'],
      placeId: json['place_id'],
      slotNumber: json['slot_number'],
      isOccupied: json['is_occupied'],
      qrCode: json['qr_code'],
    );
  }
}