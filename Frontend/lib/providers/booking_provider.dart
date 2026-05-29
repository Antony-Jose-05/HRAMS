import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/api_client.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  BookingProvider(this._bookingService);

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, bookings, message) = await _bookingService.getAllBookings();
      
      if (success) {
        _bookings = bookings;
        _error = null;
      } else {
        _error = message;
      }
    } catch (e) {
      _error = 'Error fetching bookings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(
    int roomId,
    String guestName,
    String phone,
    DateTime checkInDate,
    DateTime checkOutDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, booking, message) = await _bookingService.createBooking(
        roomId, guestName, phone, checkInDate, checkOutDate,
      );

      if (success && booking != null) {
        _bookings.add(booking);
        _error = null;
      } else {
        _error = message;
      }
      return success;
    } catch (e) {
      _error = 'Error creating booking: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBooking(
    int id,
    String? guestName,
    String? phone,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? status,
  ) async {
    try {
      final (success, updatedBooking, message) = await _bookingService.updateBooking(
        id,
        guestName,
        phone,
        checkInDate,
        checkOutDate,
        status,
      );

      if (success && updatedBooking != null) {
        final index = _bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          _bookings[index] = updatedBooking;
        }
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating booking: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBooking(int id) async {
    try {
      final (success, message) = await _bookingService.deleteBooking(id);

      if (success) {
        _bookings.removeWhere((b) => b.id == id);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting booking: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchBookingsByRoom(int roomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, bookings, message) = await _bookingService.getBookingsByRoom(roomId);

      if (success) {
        _bookings = bookings;
        _error = null;
      } else {
        _error = message;
      }
    } catch (e) {
      _error = 'Error fetching room bookings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get totalBookings => _bookings.length;

  int get todayBookings => _bookings
      .where((b) =>
          b.checkInDate.year == DateTime.now().year &&
          b.checkInDate.month == DateTime.now().month &&
          b.checkInDate.day == DateTime.now().day)
      .length;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Factory function to create BookingProvider
Future<BookingProvider> createBookingProvider() async {
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(prefs: prefs);
  final bookingService = BookingService(apiClient: apiClient);
  return BookingProvider(bookingService);
}
