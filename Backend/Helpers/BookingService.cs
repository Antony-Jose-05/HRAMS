using HotelBackend.Data;
using HotelBackend.DTOs;
using HotelBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace HotelBackend.Helpers;

/// <summary>
/// BookingService handles all booking operations
/// (create, read, update, delete with validation)
/// Ensures no double-bookings and validates dates
/// </summary>
public class BookingService
{
    private readonly AppDbContext _context; // Database access

    public BookingService(AppDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Get all bookings from database (for admin dashboard)
    /// </summary>
    public async Task<List<BookingDTO>> GetAllBookingsAsync()
    {
        // Include() loads the related Room object with each booking
        var bookings = await _context.Bookings.Include(b => b.Room).ToListAsync();
        return bookings.Select(MapToDTO).ToList();
    }

    /// <summary>
    /// Get a single booking by ID
    /// </summary>
    public async Task<BookingDTO?> GetBookingByIdAsync(int id)
    {
        var booking = await _context.Bookings
            .Include(b => b.Room)
            .FirstOrDefaultAsync(b => b.Id == id);
        return booking == null ? null : MapToDTO(booking);
    }

    /// <summary>
    /// Get all bookings for a specific room
    /// Used to see booking history for a room 
    /// </summary>
    public async Task<List<BookingDTO>> GetBookingsByRoomAsync(int roomId)
    {
        var bookings = await _context.Bookings
            .Include(b => b.Room)
            .Where(b => b.RoomId == roomId)
            .ToListAsync();
        return bookings.Select(MapToDTO).ToList();
    }

    /// <summary>
    /// Create a new booking with validation
    /// Returns: (success, error_message, booking_data)
    /// </summary>
    public async Task<(bool success, string message, BookingDTO? data)> CreateBookingAsync(CreateBookingDTO dto)
    {
        // ===== VALIDATION 1: Date validation =====
        // Check-out date must be AFTER check-in date
        if (dto.CheckInDate >= dto.CheckOutDate)
            return (false, "Check-out date must be after check-in date", null);

        // ===== VALIDATION 2: Future date validation =====
        // Can't book a room in the past
        if (dto.CheckInDate < DateTime.Today)
            return (false, "Check-in date cannot be in the past", null);

        // ===== VALIDATION 3: Room exists =====
        var room = await _context.Rooms.FindAsync(dto.RoomId);
        if (room == null)
            return (false, "Room not found", null);

        // ===== VALIDATION 4: No double-booking =====
        // Check if this room has any conflicting bookings
        // A conflict occurs when another booking's dates overlap with these dates
        var conflict = await _context.Bookings.AnyAsync(b =>
            b.RoomId == dto.RoomId &&
            b.Status != "CheckedOut" && // Only active bookings matter
            b.CheckOutDate > dto.CheckInDate && // Other booking ends after our start
            b.CheckInDate < dto.CheckOutDate // Other booking starts before our end
        );

        if (conflict)
            return (false, "Room is not available for selected dates", null);

        // ===== All validation passed - create booking =====
        var booking = new Booking
        {
            RoomId = dto.RoomId,
            GuestName = dto.GuestName,
            Phone = dto.Phone,
            CheckInDate = dto.CheckInDate,
            CheckOutDate = dto.CheckOutDate,
            Status = "Reserved" // Initial status
        };

        _context.Bookings.Add(booking);
        await _context.SaveChangesAsync();

        // Reload booking with room data
        await _context.Entry(booking).Reference(b => b.Room).LoadAsync();

        return (true, "Booking created successfully", MapToDTO(booking));
    }

    /// <summary>
    /// Update booking details (admin only)
    /// </summary>
    public async Task<(bool success, string message, BookingDTO? data)> UpdateBookingAsync(int id, UpdateBookingDTO dto)
    {
        // Find booking
        var booking = await _context.Bookings
            .Include(b => b.Room)
            .FirstOrDefaultAsync(b => b.Id == id);
        if (booking == null)
            return (false, "Booking not found", null);

        // Use provided values or fall back to existing values
        var checkIn = dto.CheckInDate ?? booking.CheckInDate;
        var checkOut = dto.CheckOutDate ?? booking.CheckOutDate;

        // ===== Validate new dates if provided =====
        if (dto.CheckInDate.HasValue || dto.CheckOutDate.HasValue)
        {
            if (checkIn >= checkOut)
                return (false, "Check-out date must be after check-in date", null);

            if (checkIn < DateTime.Today)
                return (false, "Check-in date cannot be in the past", null);

            // Check for NEW conflicts (excluding this booking)
            var conflict = await _context.Bookings.AnyAsync(b =>
                b.Id != id && // Don't check against itself
                b.RoomId == booking.RoomId &&
                b.Status != "CheckedOut" &&
                b.CheckOutDate > checkIn &&
                b.CheckInDate < checkOut
            );

            if (conflict)
                return (false, "Room is not available for selected dates", null);
        }

        // ===== Update fields that were provided =====
        if (!string.IsNullOrEmpty(dto.GuestName))
            booking.GuestName = dto.GuestName;
        if (!string.IsNullOrEmpty(dto.Phone))
            booking.Phone = dto.Phone;
        if (dto.CheckInDate.HasValue)
            booking.CheckInDate = dto.CheckInDate.Value;
        if (dto.CheckOutDate.HasValue)
            booking.CheckOutDate = dto.CheckOutDate.Value;
        if (!string.IsNullOrEmpty(dto.Status))
            booking.Status = dto.Status; // e.g., "CheckedIn", "CheckedOut"

        await _context.SaveChangesAsync();
        return (true, "Booking updated successfully", MapToDTO(booking));
    }

    /// <summary>
    /// Delete (cancel) a booking
    /// </summary>
    public async Task<(bool success, string message)> DeleteBookingAsync(int id)
    {
        var booking = await _context.Bookings.FindAsync(id);
        if (booking == null)
            return (false, "Booking not found");

        _context.Bookings.Remove(booking);
        await _context.SaveChangesAsync();
        return (true, "Booking deleted successfully");
    }

    /// <summary>
    /// Convert Booking model to BookingDTO (for API responses)
    /// </summary>
    private BookingDTO MapToDTO(Booking booking)
    {
        return new BookingDTO
        {
            Id = booking.Id,
            RoomId = booking.RoomId,
            GuestName = booking.GuestName,
            Phone = booking.Phone,
            CheckInDate = booking.CheckInDate,
            CheckOutDate = booking.CheckOutDate,
            Status = booking.Status,
            Room = booking.Room == null ? null : new RoomDTO
            {
                Id = booking.Room.Id,
                RoomNumber = booking.Room.RoomNumber,
                Type = booking.Room.Type,
                Price = booking.Room.Price,
                Floor = booking.Room.Floor,
                Status = "Available"
            }
        };
    }
}
