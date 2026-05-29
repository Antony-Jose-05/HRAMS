using HotelBackend.Data;
using HotelBackend.DTOs;
using HotelBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace HotelBackend.Helpers;

/// <summary>
/// RoomService handles all room-related operations
/// (list, create, update, delete, check availability)
/// </summary>
public class RoomService
{
    private readonly AppDbContext _context; // Database access

    public RoomService(AppDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Get all rooms from database
    /// </summary>
    public async Task<List<RoomDTO>> GetAllRoomsAsync()
    {
        var rooms = await _context.Rooms.ToListAsync();
        return rooms.Select(MapToDTO).ToList();
    }

    /// <summary>
    /// Get a single room by ID
    /// </summary>
    public async Task<RoomDTO?> GetRoomByIdAsync(int id)
    {
        var room = await _context.Rooms.FindAsync(id);
        return room == null ? null : MapToDTO(room);
    }

    /// <summary>
    /// Get rooms that are available for a date range
    /// A room is available if it has NO active bookings in that date range
    /// </summary>
    public async Task<List<RoomDTO>> GetAvailableRoomsAsync(DateTime checkInDate, DateTime checkOutDate)
    {
        // Step 1: Find all room IDs that have CONFLICTING bookings
        // A conflict happens when:
        // - Booking status is NOT "CheckedOut" (still active)
        // - AND booking checkout date is AFTER our check-in date
        // - AND booking check-in date is BEFORE our checkout date
        var bookedRoomIds = await _context.Bookings
            .Where(b => b.Status != "CheckedOut" &&
                        b.CheckOutDate > checkInDate &&
                        b.CheckInDate < checkOutDate)
            .Select(b => b.RoomId)
            .Distinct()
            .ToListAsync();

        // Step 2: Get all rooms EXCEPT those with conflicts
        var availableRooms = await _context.Rooms
            .Where(r => !bookedRoomIds.Contains(r.Id))
            .ToListAsync();

        return availableRooms.Select(MapToDTO).ToList();
    }

    /// <summary>
    /// Create a new room (admin only)
    /// </summary>
    public async Task<RoomDTO?> CreateRoomAsync(CreateRoomDTO dto)
    {
        // Check if room number already exists (must be unique)
        if (await _context.Rooms.AnyAsync(r => r.RoomNumber == dto.RoomNumber))
            return null; // Return null if duplicate

        // Create new room object
        var room = new Room
        {
            RoomNumber = dto.RoomNumber,
            Type = dto.Type,
            Price = dto.Price,
            Floor = dto.Floor
        };

        // Add to database and save
        _context.Rooms.Add(room);
        await _context.SaveChangesAsync();

        return MapToDTO(room);
    }

    /// <summary>
    /// Update room details (admin only)
    /// </summary>
    public async Task<RoomDTO?> UpdateRoomAsync(int id, UpdateRoomDTO dto)
    {
        // Find room by ID
        var room = await _context.Rooms.FindAsync(id);
        if (room == null) return null; // Room not found

        // Update only fields that were provided
        if (!string.IsNullOrEmpty(dto.Type))
            room.Type = dto.Type;
        if (dto.Price.HasValue)
            room.Price = dto.Price.Value;
        if (dto.Floor.HasValue)
            room.Floor = dto.Floor.Value;

        // Save changes to database
        await _context.SaveChangesAsync();
        return MapToDTO(room);
    }

    /// <summary>
    /// Delete a room (admin only)
    /// WARNING: This also deletes all related bookings due to cascade delete
    /// </summary>
    public async Task<bool> DeleteRoomAsync(int id)
    {
        var room = await _context.Rooms.FindAsync(id);
        if (room == null) return false; // Room not found

        _context.Rooms.Remove(room);
        await _context.SaveChangesAsync();
        return true;
    }

    /// <summary>
    /// Convert Room model to RoomDTO (for API responses)
    /// </summary>
    private RoomDTO MapToDTO(Room room)
    {
        return new RoomDTO
        {
            Id = room.Id,
            RoomNumber = room.RoomNumber,
            Type = room.Type,
            Price = room.Price,
            Floor = room.Floor,
            Status = room.Status
        };
    }
}
