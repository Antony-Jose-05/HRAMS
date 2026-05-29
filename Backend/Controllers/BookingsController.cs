using HotelBackend.DTOs;
using HotelBackend.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HotelBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly BookingService _bookingService;

    public BookingsController(BookingService bookingService)
    {
        _bookingService = bookingService;
    }

    /// <summary>
    /// Get all bookings
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<BookingDTO>>> GetAllBookings()
    {
        var bookings = await _bookingService.GetAllBookingsAsync();
        return Ok(bookings);
    }

    /// <summary>
    /// Get booking by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<BookingDTO>> GetBookingById(int id)
    {
        var booking = await _bookingService.GetBookingByIdAsync(id);
        if (booking == null)
            return NotFound(new ErrorResponseDTO { Message = "Booking not found", Code = "NOT_FOUND" });

        return Ok(booking);
    }

    /// <summary>
    /// Get all bookings for a specific room
    /// </summary>
    [HttpGet("room/{roomId}")]
    public async Task<ActionResult<List<BookingDTO>>> GetBookingsByRoom(int roomId)
    {
        var bookings = await _bookingService.GetBookingsByRoomAsync(roomId);
        return Ok(bookings);
    }

    /// <summary>
    /// Create a new booking
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    public async Task<ActionResult<BookingDTO>> CreateBooking([FromBody] CreateBookingDTO dto)
    {
        if (string.IsNullOrWhiteSpace(dto.GuestName) || string.IsNullOrWhiteSpace(dto.Phone))
            return BadRequest(new ErrorResponseDTO { Message = "Guest name and phone are required", Code = "INVALID_INPUT" });

        var (success, message, data) = await _bookingService.CreateBookingAsync(dto);

        if (!success)
            return BadRequest(new ErrorResponseDTO { Message = message, Code = "BOOKING_ERROR" });

        return CreatedAtAction(nameof(GetBookingById), new { id = data!.Id }, data);
    }

    /// <summary>
    /// Update booking details (Admin only)
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<BookingDTO>> UpdateBooking(int id, [FromBody] UpdateBookingDTO dto)
    {
        var (success, message, data) = await _bookingService.UpdateBookingAsync(id, dto);

        if (!success)
            return BadRequest(new ErrorResponseDTO { Message = message, Code = "UPDATE_ERROR" });

        return Ok(data);
    }

    /// <summary>
    /// Delete a booking (Cancel booking) - Admin only
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteBooking(int id)
    {
        var (success, message) = await _bookingService.DeleteBookingAsync(id);

        if (!success)
            return NotFound(new ErrorResponseDTO { Message = message, Code = "NOT_FOUND" });

        return NoContent();
    }
}
