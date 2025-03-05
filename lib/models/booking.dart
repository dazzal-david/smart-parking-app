class Booking {
  final String id;
  final String userId;
  final String placeId;
  final String slotId;
  final DateTime bookingTime;

  Booking({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.slotId,
    required this.bookingTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      placeId: json['place_id'],
      slotId: json['slot_id'],
      bookingTime: DateTime.parse(json['booking_time']),
    );
  }
}