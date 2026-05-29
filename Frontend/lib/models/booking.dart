import 'room.dart';

class Booking {
  final int id;
  final int roomId;
  final String guestName;
  final String phone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String status; // "Reserved", "CheckedIn", "CheckedOut"
  final Room? room;

  const Booking({
    required this.id,
    required this.roomId,
    required this.guestName,
    required this.phone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    this.room,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int? ?? 0,
      roomId: json['roomId'] as int? ?? 0,
      guestName: json['guestName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      status: json['status'] as String? ?? 'Reserved',
      room: json['room'] != null ? Room.fromJson(json['room'] as Map<String, dynamic>) : null,
    );
  }

  String get statusName {
    switch (status) {
      case 'CheckedIn':
        return 'Checked In';
      case 'CheckedOut':
        return 'Checked Out';
      case 'Reserved':
      default:
        return 'Reserved';
    }
  }

  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
  }
}
