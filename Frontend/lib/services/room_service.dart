import '../models/room.dart';
import 'api_client.dart';

class RoomService {
  final ApiClient _apiClient;

  RoomService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch all rooms from API
  Future<(bool, List<Room>, String)> getAllRooms() async {
    try {
      final response = await _apiClient.get<List>(
        '/rooms',
        fromJson: (json) => json as List,
      );

      final List<Room> rooms = response
          .map((item) => Room.fromJson(item as Map<String, dynamic>))
          .toList();

      return (true, rooms, 'Rooms fetched successfully');
    } catch (e) {
      return (false, <Room>[], 'Error fetching rooms: $e');
    }
  }

  Future<(bool, Room?, String)> getRoomById(int id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/rooms/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final room = Room.fromJson(response);
      return (true, room, 'Room fetched successfully');
    } catch (e) {
      return (false, null, 'Error fetching room: $e');
    }
  }

  /// Fetch available rooms for a date range
  Future<(bool, List<Room>, String)> getAvailableRooms(
    DateTime checkInDate,
    DateTime checkOutDate,
  ) async {
    try {
      final checkInStr = checkInDate.toIso8601String();
      final checkOutStr = checkOutDate.toIso8601String();

      final response = await _apiClient.get<List>(
        '/rooms/available?checkInDate=$checkInStr&checkOutDate=$checkOutStr',
        fromJson: (json) => json as List,
      );

      final List<Room> rooms = response
          .map((item) => Room.fromJson(item as Map<String, dynamic>))
          .toList();

      return (true, rooms, 'Available rooms fetched');
    } catch (e) {
      return (false, <Room>[], 'Error fetching available rooms: $e');
    }
  }

  Future<(bool, Room?, String)> createRoom(
    String roomNumber,
    String type,
    double price,
    int floor,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/rooms',
        {
          'roomNumber': roomNumber,
          'type': type,
          'price': price,
          'floor': floor,
        },
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: true,
      );

      final room = Room.fromJson(response);
      return (true, room, 'Room created successfully');
    } catch (e) {
      return (false, null, 'Error creating room: $e');
    }
  }

  Future<(bool, Room?, String)> updateRoom(
    int id,
    String? type,
    double? price,
    int? floor,
  ) async {
    try {
      final body = <String, dynamic>{};
      if (type != null) body['type'] = type;
      if (price != null) body['price'] = price;
      if (floor != null) body['floor'] = floor;

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/rooms/$id',
        body,
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: true,
      );

      final room = Room.fromJson(response);
      return (true, room, 'Room updated successfully');
    } catch (e) {
      return (false, null, 'Error updating room: $e');
    }
  }

  Future<(bool, String)> deleteRoom(int id) async {
    try {
      await _apiClient.delete('/rooms/$id', requiresAuth: true);
      return (true, 'Room deleted successfully');
    } catch (e) {
      return (false, 'Error deleting room: $e');
    }
  }
}
