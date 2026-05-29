import '../models/booking.dart';
import 'api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch all bookings from API (requires authentication)
  Future<(bool, List<Booking>, String)> getAllBookings() async {
    try {
      final response = await _apiClient.get<List>(
        '/bookings',
        fromJson: (json) => json as List,
        requiresAuth: true,
      );

      final List<Booking> bookings = response
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();

      return (true, bookings, 'Bookings fetched successfully');
    } catch (e) {
      return (false, <Booking>[], 'Error fetching bookings: $e');
    }
  }

  Future<(bool, Booking?, String)> getBookingById(int id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/bookings/$id',
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: true,
      );

      final booking = Booking.fromJson(response);
      return (true, booking, 'Booking fetched successfully');
    } catch (e) {
      return (false, null, 'Error fetching booking: $e');
    }
  }

  /// Fetch all bookings for a specific room
  Future<(bool, List<Booking>, String)> getBookingsByRoom(
    int roomId,
  ) async {
    try {
      final response = await _apiClient.get<List>(
        '/bookings/room/$roomId',
        fromJson: (json) => json as List,
        requiresAuth: true,
      );

      final List<Booking> bookings = response
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();

      return (true, bookings, 'Room bookings fetched');
    } catch (e) {
      return (false, <Booking>[], 'Error fetching room bookings: $e');
    }
  }

  Future<(bool, Booking?, String)> createBooking(
    int roomId,
    String guestName,
    String phone,
    DateTime checkInDate,
    DateTime checkOutDate,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/bookings',
        {
          'roomId': roomId,
          'guestName': guestName,
          'phone': phone,
          'checkInDate': checkInDate.toIso8601String(),
          'checkOutDate': checkOutDate.toIso8601String(),
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final booking = Booking.fromJson(response);
      return (true, booking, 'Booking created successfully');
    } catch (e) {
      return (false, null, 'Error creating booking: $e');
    }
  }

  Future<(bool, Booking?, String)> updateBooking(
    int id,
    String? guestName,
    String? phone,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? status,
  ) async {
    try {
      final body = <String, dynamic>{};
      if (guestName != null) body['guestName'] = guestName;
      if (phone != null) body['phone'] = phone;
      if (checkInDate != null) body['checkInDate'] = checkInDate.toIso8601String();
      if (checkOutDate != null) body['checkOutDate'] = checkOutDate.toIso8601String();
      if (status != null) body['status'] = status;

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/bookings/$id',
        body,
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: true,
      );

      final booking = Booking.fromJson(response);
      return (true, booking, 'Booking updated successfully');
    } catch (e) {
      return (false, null, 'Error updating booking: $e');
    }
  }

  Future<(bool, String)> deleteBooking(int id) async {
    try {
      await _apiClient.delete('/bookings/$id', requiresAuth: true);
      return (true, 'Booking deleted successfully');
    } catch (e) {
      return (false, 'Error deleting booking: $e');
    }
  }
}
