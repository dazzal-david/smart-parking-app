class BookingHistory {
  final String id;
  final String name;
  final String address;
  final DateTime bookingTime;

  BookingHistory({
    required this.id,
    required this.name,
    required this.address,
    required this.bookingTime,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      bookingTime: DateTime.parse(json['booking_time']),
    );
  }
}