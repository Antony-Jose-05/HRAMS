import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/room_card.dart';
import '../widgets/booking_form_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchAllRooms();
      context.read<BookingProvider>().fetchAllBookings();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isCheckIn) async {
    final now = DateTime.now();
    final picked =
        await Navigator.of(context).push<DateTime>(PageRouteBuilder<DateTime>(
      opaque: false,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.1),
      // TIP: Change the milliseconds below to adjust the fade IN speed
      transitionDuration: const Duration(milliseconds: 300),
      // TIP: Change the milliseconds below to adjust the fade OUT speed
      reverseTransitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B5DF5),
              surface: Color(0xFFF8FAFC),
              onSurface: Color(0xFF0F172A),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: DatePickerDialog(
            initialDate: isCheckIn
                ? (_checkIn ?? now)
                : (_checkOut ?? now.add(const Duration(days: 1))),
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          // TIP: Adjust the '3' below to change the blur intensity (higher = more blur)
          filter: ui.ImageFilter.blur(
              sigmaX: 3 * animation.value, sigmaY: 3 * animation.value),
          child: FadeScaleTransition(
            animation: animation,
            child: child,
          ),
        );
      },
    ));
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          // Auto-clear checkout if it's before new checkin
          if (_checkOut != null && _checkOut!.isBefore(picked)) {
            _checkOut = null;
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Consumer2<RoomProvider, BookingProvider>(
      builder: (context, roomProvider, bookingProvider, _) {
        final rooms = roomProvider.rooms;
        final totalRooms = rooms.length;
        final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
        final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;
        final bookingsToday = bookingProvider.todayBookings;

        return Padding(
          // TIP: Adjust the '80' below to change the gap between the scrolling area and the nav bar
          padding: const EdgeInsets.only(bottom: 83),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- APP BAR ---
                _buildAppBar(),
                const SizedBox(height: 24),

                // --- STATISTICS GRID ---
                _buildSectionTitle('Overview'),
                const SizedBox(height: 12),
                _buildStatsGrid(totalRooms, availableRooms, occupiedRooms, bookingsToday),
                const SizedBox(height: 28),

                // --- DATE SEARCH ---
                _buildSectionTitle('Check Availability'),
                const SizedBox(height: 12),
                _buildDateSearch(),
                const SizedBox(height: 28),

                // --- ROOM GRID ---
                _buildSectionTitle('Rooms'),
                const SizedBox(height: 12),
                _buildRoomGrid(rooms),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- APP BAR ---
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark background like image
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Kochi, Kerala',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Notification bell
            Stack(
              children: [
                _buildIconButton(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B5DF5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Profile avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF0F172A), size: 22),
    );
  }

  // --- SECTION TITLE ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // --- STATISTICS GRID ---
  Widget _buildStatsGrid(int totalRooms, int availableRooms, int occupiedRooms, int bookingsToday) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        StatCard(
          icon: Icons.meeting_room_outlined,
          label: 'Total Rooms',
          value: '$totalRooms',
          iconColor: const Color(0xFF3B5DF5),
          iconBgColor: const Color(0xFF3B5DF5).withValues(alpha: 0.15),
        ),
        StatCard(
          icon: Icons.check_circle_outline,
          label: 'Available',
          value: '$availableRooms',
          iconColor: const Color(0xFF22C55E),
          iconBgColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
        ),
        StatCard(
          icon: Icons.do_not_disturb_on_outlined,
          label: 'Occupied',
          value: '$occupiedRooms',
          iconColor: const Color(0xFFEF4444),
          iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
        ),
        StatCard(
          icon: Icons.calendar_today_outlined,
          label: 'Bookings Today',
          value: '$bookingsToday',
          iconColor: const Color(0xFFFBBF24),
          iconBgColor: const Color(0xFFFBBF24).withValues(alpha: 0.15),
        ),
      ],
    );
  }

  // --- DATE SEARCH SECTION ---
  Widget _buildDateSearch() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Check-in',
                  value: _checkIn != null
                      ? dateFormat.format(_checkIn!)
                      : 'Select date',
                  icon: Icons.login_outlined,
                  onTap: () => _pickDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Check-out',
                  value: _checkOut != null
                      ? dateFormat.format(_checkOut!)
                      : 'Select date',
                  icon: Icons.logout_outlined,
                  onTap: () => _pickDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_checkIn == null || _checkOut == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both dates')),
                        );
                        return;
                      }
                      
                      if (!_checkOut!.isAfter(_checkIn!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Check-out must be after check-in')),
                        );
                        return;
                      }

                      final roomProvider = context.read<RoomProvider>();
                      final success = await roomProvider
                          .fetchAvailableRooms(_checkIn!, _checkOut!);
                      
                      if (mounted && success) {
                        final count = roomProvider.rooms.length;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$count room${count == 1 ? '' : 's'} available from '
                              '${dateFormat.format(_checkIn!)} to '
                              '${dateFormat.format(_checkOut!)}'
                            ),
                            backgroundColor: const Color(0xFF22C55E),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5DF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search Availability',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _checkIn = null;
                    _checkOut = null;
                  });
                  context.read<RoomProvider>().fetchAllRooms();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF93A8FF), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: value == 'Select date'
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ROOM GRID ---
  Widget _buildRoomGrid(List<Room> rooms) {
    final displayRooms = rooms.take(6).toList();
    if (displayRooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No rooms available', style: TextStyle(color: Color(0xFF475569))),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemCount: displayRooms.length,
      itemBuilder: (context, index) {
        return RoomCard(
          room: displayRooms[index],
          onTap: () => _showRoomDetail(displayRooms[index]),
        );
      },
    );
  }

  void _showRoomDetail(Room room) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Room ${room.number}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Type', room.typeName),
                    _buildDetailRow('Status', room.statusName),
                    _buildDetailRow('Floor', '${room.floor}'),
                    _buildDetailRow(
                        'Price', '\$${room.pricePerNight.toInt()} / night'),
                    const SizedBox(height: 24),
                    if (room.status == RoomStatus.available)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // Close current sheet first
                            Navigator.of(context).pop();
                            // Show the booking form sheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => BookingFormSheet(room: room),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B5DF5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(
              sigmaX: 3 * animation.value, sigmaY: 3 * animation.value),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
