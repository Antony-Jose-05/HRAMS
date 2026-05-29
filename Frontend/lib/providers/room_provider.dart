import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';
import '../services/api_client.dart';
import '../services/room_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService;

  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  RoomStatus? _filterStatus;
  bool _isLoading = false;
  String? _error;

  bool _filterActive = false;

  RoomProvider(this._roomService);

  List<Room> get rooms => _filterActive ? _filteredRooms : _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RoomStatus? get filterStatus => _filterStatus;

  Future<void> fetchAllRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, rooms, message) = await _roomService.getAllRooms();
      
      if (success) {
        _rooms = rooms;
        _filteredRooms = rooms;
        _filterActive = false;
        _filterStatus = null;
        _error = null;
      } else {
        _error = message;
      }
    } catch (e) {
      _error = 'Error fetching rooms: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchAvailableRooms(DateTime checkInDate, DateTime checkOutDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, rooms, message) = await _roomService.getAvailableRooms(checkInDate, checkOutDate);
      
      if (success) {
        _rooms = rooms;
        _filteredRooms = rooms;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error fetching available rooms: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void filterByStatus(RoomStatus? status) {
    _filterStatus = status;
    _filterActive = status != null;
    
    if (status == null) {
      _filteredRooms = _rooms;
    } else {
      _filteredRooms = _rooms.where((room) => room.status == status).toList();
    }
    
    notifyListeners();
  }

  Future<bool> createRoom(String roomNumber, String type, double price, int floor) async {
    try {
      final (success, room, message) = await _roomService.createRoom(roomNumber, type, price, floor);
      
      if (success && room != null) {
        _rooms.add(room);
        _filteredRooms.add(room);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error creating room: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoom(int id, String? type, double? price, int? floor) async {
    try {
      final (success, updatedRoom, message) = await _roomService.updateRoom(id, type, price, floor);
      
      if (success && updatedRoom != null) {
        final index = _rooms.indexWhere((r) => r.id == id);
        if (index != -1) {
          _rooms[index] = updatedRoom;
          final filteredIndex = _filteredRooms.indexWhere((r) => r.id == id);
          if (filteredIndex != -1) {
            _filteredRooms[filteredIndex] = updatedRoom;
          }
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
      _error = 'Error updating room: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoom(int id) async {
    try {
      final (success, message) = await _roomService.deleteRoom(id);
      
      if (success) {
        _rooms.removeWhere((r) => r.id == id);
        _filteredRooms.removeWhere((r) => r.id == id);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting room: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Factory function to create RoomProvider
Future<RoomProvider> createRoomProvider() async {
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(prefs: prefs);
  final roomService = RoomService(apiClient: apiClient);
  return RoomProvider(roomService);
}
