import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';
import '../widgets/room_card.dart';
import '../widgets/booking_form_sheet.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  RoomStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchAllRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Consumer<RoomProvider>(
      builder: (context, roomProvider, _) {
        final filteredRooms = _selectedFilter == null
            ? roomProvider.rooms
            : roomProvider.rooms.where((r) => r.status == _selectedFilter).toList();

        return Padding(
          // TIP: Adjust the '100' below to change the gap between the bottom of the list and the nav bar
          padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 69),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'All Rooms',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${filteredRooms.length} rooms found',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Available', RoomStatus.available),
                    const SizedBox(width: 8),
                    _buildFilterChip('Occupied', RoomStatus.occupied),
                    const SizedBox(width: 8),
                    _buildFilterChip('Reserved', RoomStatus.reserved),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Room grid
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF3B5DF5),
                  onRefresh: () => context.read<RoomProvider>().fetchAllRooms(),
                  child: roomProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : roomProvider.error != null
                        ? ListView(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    roomProvider.error!,
                                    style: const TextStyle(color: Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : filteredRooms.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Text(
                                        'No rooms found',
                                        style: TextStyle(color: Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.92,
                                ),
                                itemCount: filteredRooms.length,
                                itemBuilder: (context, index) {
                                  return RoomCard(
                                    room: filteredRooms[index],
                                    onTap: () => _showRoomSheet(filteredRooms[index]),
                                  );
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

  Widget _buildFilterChip(String label, RoomStatus? status) {
    final isSelected = _selectedFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B5DF5)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B5DF5) : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showRoomSheet(Room room) {
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
                    _detailRow('Type', room.typeName),
                    _detailRow('Status', room.statusName),
                    _detailRow('Floor', '${room.floor}'),
                    _detailRow(
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
          // TIP: Adjust the '8' below to change the blur intensity (higher = more blur)
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
