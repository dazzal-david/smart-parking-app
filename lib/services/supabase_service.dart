import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_parking_app/models/parking_place.dart';
import 'package:smart_parking_app/models/parking_slot.dart';
import 'package:smart_parking_app/models/booking.dart';
import 'package:smart_parking_app/models/booking_history.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }


  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }


  Future<List<ParkingPlace>> getParkingPlaces() async {
    final response = await _supabaseClient
        .from('parking_places')
        .select();

    return (response as List)
        .map((place) => ParkingPlace.fromJson(place))
        .toList();
  }

  Future<List<ParkingSlot>> getParkingSlots(String placeId) async {
    final response = await _supabaseClient
        .from('parking_slots')
        .select()
        .eq('place_id', placeId);

    return (response as List)
        .map((slot) => ParkingSlot.fromJson(slot))
        .toList();
  }

  Future<void> bookParkingSlot(String placeId, String slotId) async {
    final userId = _supabaseClient.auth.currentUser!.id;
    
    // Start a transaction by using RPC
    await _supabaseClient.rpc('book_parking_slot', params: {
      'user_id': userId,
      'place_id': placeId,
      'slot_id': slotId,
      'booking_time': DateTime.now().toIso8601String(),
    });
  }

  // Add this getter to your SupabaseService class
  String get currentUserId => _supabaseClient.auth.currentUser!.id;

  Future<List<Booking>> getUserBookings() async {
    final userId = _supabaseClient.auth.currentUser!.id;
    
    final response = await _supabaseClient
        .from('bookings')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map((booking) => Booking.fromJson(booking))
        .toList();
  }

  // Add this method to your SupabaseService class
Future<void> bookParkingSlotWithDetails(
  String placeId, 
  String slotId, 
  int durationHours, 
  String vehicleNumber
) async {
  final userId = _supabaseClient.auth.currentUser!.id;
  

  await _supabaseClient.from('bookings_history').insert({
        'user_id': userId,
        'parking_place_id': placeId,
        'name': placeId,
        'address': placeId,
        'booking_time': DateTime.now().toUtc().toIso8601String(),
      });
}

Future<Map<String, dynamic>> getDashboardStats() async {
  try {
    final response = await _supabaseClient
        .rpc('get_dashboard_stats');
    
    return Map<String, dynamic>.from(response ?? {});
  } catch (e) {
    print('Error fetching dashboard stats: $e');
    return {};
  }
}

Future<List<BookingHistory>> getBookingHistory() async {
  final response = await _supabaseClient
      .from('bookings_history')
      .select()
      .order('booking_time', ascending: false);

  return (response as List)
      .map((booking) => BookingHistory.fromJson(booking))
      .toList();
}

// Add these methods to your existing SupabaseService class

Future<String> signUp(String email, String password) async {
  try {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Registration failed');
    }

    return response.user!.id;
  } catch (e) {
    throw Exception('Registration failed: ${e.toString()}');
  }
}

Future<void> createUserProfile({
  required String userId,
  required String username,
  required String phoneNumber,
  required String address,
}) async {
  try {
    await _supabaseClient.from('user_profiles').insert({
      'id': userId,
      'username': username,
      'phone_number': phoneNumber,
      'address': address,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  } catch (e) {
    throw Exception('Failed to create user profile: ${e.toString()}');
  }
}

Future<void> addVehicle({
  required String userId,
  required String vehicleNumber,
  required String vehicleType,
  String? brand,
  String? model,
}) async {
  try {
    await _supabaseClient.from('vehicles').insert({
      'user_id': userId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'brand': brand,
      'model': model,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  } catch (e) {
    throw Exception('Failed to add vehicle: ${e.toString()}');
  }
}

// Add method to get active bookings with time remaining
Future<List<Map<String, dynamic>>> getActiveBookings() async {
  try {
    final userId = _supabaseClient.auth.currentUser!.id;
    final response = await _supabaseClient
        .from('active_bookings_view')
        .select()
        .eq('user_id', userId);
        
    if (response == null) return [];
    
    return (response as List).map((booking) {
      return Map<String, dynamic>.from(booking);
    }).toList();
  } catch (e) {
    print('Error fetching active bookings: $e');
    return [];
  }
}

  Future<void> deregisterParking(String bookingId, String slotId) async {
  try {
    await _supabaseClient.rpc('deregister_parking', params: {
      'booking_id': bookingId,
      'slot_id': slotId,
    });
  } catch (e) {
    print('Error deregistering parking: $e');
    throw Exception('Failed to deregister parking: ${e.toString()}');
  }
}

  Future<void> extendBooking(String bookingId, int additionalHours) async {
    try {
      await _supabaseClient.rpc('extend_booking', params: {
        'booking_id': bookingId,
        'additional_hours': additionalHours,
      });
    } catch (e) {
      print('Error extending booking: $e');
      throw Exception('Failed to extend booking: ${e.toString()}');
    }
  }


  Future<Map<String, dynamic>> getUserProfile() async {
  try {
    final response = await _supabaseClient
        .from('user_profiles')
        .select()
        .eq('id', _supabaseClient.auth.currentUser!.id)
        .single();
    
    return response as Map<String, dynamic>;
  } catch (e) {
    print('Error fetching user profile: $e');
    return {};
  }
}

  Future<List<Map<String, dynamic>>> getUserVehicles() async {
  try {
    final response = await _supabaseClient
        .from('vehicles')
        .select()
        .eq('user_id', _supabaseClient.auth.currentUser!.id);
    
    return (response as List).cast<Map<String, dynamic>>();
  } catch (e) {
    print('Error fetching user vehicles: $e');
    return [];
  }
}

  // Add these methods to your SupabaseService class

Future<void> updateVehicle(
  String vehicleId,
  String vehicleNumber,
  String vehicleType,
  String? brand,
  String? model,
) async {
  try {
    await _supabaseClient.from('vehicles').update({
      'vehicle_number': vehicleNumber.toUpperCase(),
      'vehicle_type': vehicleType,
      'brand': brand,
      'model': model,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', vehicleId).eq('user_id', _supabaseClient.auth.currentUser!.id);
  } catch (e) {
    throw Exception('Failed to update vehicle: ${e.toString()}');
  }
}

Future<void> deleteVehicle(String vehicleId) async {
  try {
    await _supabaseClient
        .from('vehicles')
        .delete()
        .eq('id', vehicleId)
        .eq('user_id', _supabaseClient.auth.currentUser!.id);
  } catch (e) {
    throw Exception('Failed to delete vehicle: ${e.toString()}');
  }
}
}