enum RoomType { standard, deluxe, suite, penthouse }

enum RoomStatus { available, occupied, reserved }

class Room {
  final int id;
  final String number;
  final String type; // From backend: "Deluxe", "Standard", etc.
  final RoomStatus status;
  final double pricePerNight;
  final int floor;

  const Room({
    required this.id,
    required this.number,
    required this.type,
    required this.status,
    required this.pricePerNight,
    required this.floor,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int? ?? 0,
      number: json['roomNumber'] as String? ?? '',
      type: json['type'] as String? ?? 'Standard',
      status: _parseStatus(json['status'] as String? ?? 'Available'),
      pricePerNight: (json['price'] as num?)?.toDouble() ?? 0.0,
      floor: json['floor'] as int? ?? 1,
    );
  }

  static RoomStatus _parseStatus(String status) {
    return switch (status.toLowerCase()) {
      'occupied' => RoomStatus.occupied,
      'reserved' => RoomStatus.reserved,
      _ => RoomStatus.available,
    };
  }

  String get typeName => type;

  String get statusName {
    switch (status) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.reserved:
        return 'Reserved';
    }
  }

  // Keep mock data for offline testing
  static List<Room> mockRooms = const [
    Room(id: 1, number: '101', type: 'Standard', status: RoomStatus.available, pricePerNight: 89, floor: 1),
    Room(id: 2, number: '102', type: 'Standard', status: RoomStatus.occupied, pricePerNight: 89, floor: 1),
    Room(id: 3, number: '103', type: 'Deluxe', status: RoomStatus.available, pricePerNight: 149, floor: 1),
    Room(id: 4, number: '201', type: 'Deluxe', status: RoomStatus.reserved, pricePerNight: 149, floor: 2),
    Room(id: 5, number: '202', type: 'Suite', status: RoomStatus.available, pricePerNight: 249, floor: 2),
    Room(id: 6, number: '203', type: 'Standard', status: RoomStatus.occupied, pricePerNight: 89, floor: 2),
    Room(id: 7, number: '301', type: 'Suite', status: RoomStatus.occupied, pricePerNight: 249, floor: 3),
    Room(id: 8, number: '302', type: 'Deluxe', status: RoomStatus.available, pricePerNight: 149, floor: 3),
    Room(id: 9, number: '303', type: 'Penthouse', status: RoomStatus.reserved, pricePerNight: 499, floor: 3),
    Room(id: 10, number: '401', type: 'Penthouse', status: RoomStatus.available, pricePerNight: 499, floor: 4),
    Room(id: 11, number: '402', type: 'Suite', status: RoomStatus.available, pricePerNight: 249, floor: 4),
    Room(id: 12, number: '403', type: 'Standard', status: RoomStatus.occupied, pricePerNight: 89, floor: 4),
  ];
}
