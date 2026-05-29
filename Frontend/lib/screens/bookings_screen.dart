import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 69),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bookings',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Today\'s guest bookings',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildBookingCard(
                  guestName: 'Sarah Johnson',
                  roomNumber: '102',
                  checkIn: 'May 27, 2026',
                  checkOut: 'May 30, 2026',
                  status: 'Checked In',
                  statusColor: const Color(0xFF22C55E),
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  guestName: 'Michael Chen',
                  roomNumber: '201',
                  checkIn: 'May 28, 2026',
                  checkOut: 'Jun 01, 2026',
                  status: 'Reserved',
                  statusColor: const Color(0xFFFBBF24),
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  guestName: 'Emily Davis',
                  roomNumber: '301',
                  checkIn: 'May 26, 2026',
                  checkOut: 'May 29, 2026',
                  status: 'Checked In',
                  statusColor: const Color(0xFF22C55E),
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  guestName: 'Robert Wilson',
                  roomNumber: '206',
                  checkIn: 'May 27, 2026',
                  checkOut: 'May 28, 2026',
                  status: 'Checked In',
                  statusColor: const Color(0xFF22C55E),
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  guestName: 'Priya Sharma',
                  roomNumber: '309',
                  checkIn: 'May 29, 2026',
                  checkOut: 'Jun 02, 2026',
                  status: 'Reserved',
                  statusColor: const Color(0xFFFBBF24),
                ),
                const SizedBox(height: 12),
                _buildBookingCard(
                  guestName: 'James Anderson',
                  roomNumber: '403',
                  checkIn: 'May 25, 2026',
                  checkOut: 'May 27, 2026',
                  status: 'Checking Out',
                  statusColor: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard({
    required String guestName,
    required String roomNumber,
    required String checkIn,
    required String checkOut,
    required String status,
    required Color statusColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Guest row
          Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.4),
                      statusColor.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    guestName[0],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Room $roomNumber',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF64748B),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  '$checkIn  →  $checkOut',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
