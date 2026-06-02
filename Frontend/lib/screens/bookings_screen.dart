import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
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
              Text(
                '${bookingProvider.bookings.length} total bookings',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF3B5DF5),
                  onRefresh: () => context.read<BookingProvider>().fetchAllBookings(),
                  child: bookingProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : bookingProvider.error != null
                        ? ListView(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    bookingProvider.error!,
                                    style: const TextStyle(color: Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : bookingProvider.bookings.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Text(
                                        'No bookings found',
                                        style: TextStyle(color: Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: bookingProvider.bookings.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildBookingCard(bookingProvider.bookings[index]);
                                },
                              ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    switch (booking.status) {
      case 'CheckedIn':
        statusColor = const Color(0xFF22C55E);
        break;
      case 'CheckedOut':
        statusColor = const Color(0xFFEF4444);
        break;
      case 'Reserved':
      default:
        statusColor = const Color(0xFFFBBF24);
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final roomLabel = booking.room != null
        ? 'Room ${booking.room!.number}'
        : 'Room ${booking.roomId}';

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
                    booking.guestName.isNotEmpty ? booking.guestName[0] : '?',
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
                      booking.guestName,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roomLabel,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.statusName,
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
                  '${dateFormat.format(booking.checkInDate)}  →  ${dateFormat.format(booking.checkOutDate)}',
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
