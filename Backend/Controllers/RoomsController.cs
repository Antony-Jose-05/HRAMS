using HotelBackend.DTOs;
using HotelBackend.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HotelBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class RoomsController : ControllerBase
{
    private readonly RoomService _roomService;

    public RoomsController(RoomService roomService)
    {
        _roomService = roomService;
    }

    /// <summary>
    /// Get all rooms
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<RoomDTO>>> GetAllRooms()
    {
        var rooms = await _roomService.GetAllRoomsAsync();
        return Ok(rooms);
    }

    /// <summary>
    /// Get room by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<RoomDTO>> GetRoomById(int id)
    {
        var room = await _roomService.GetRoomByIdAsync(id);
        if (room == null)
            return NotFound(new ErrorResponseDTO { Message = "Room not found", Code = "NOT_FOUND" });

        return Ok(room);
    }

    /// <summary>
    /// Get available rooms for date range
    /// </summary>
    [HttpGet("availability")]
    public async Task<ActionResult<List<RoomDTO>>> GetAvailableRooms([FromQuery] DateTime checkIn, [FromQuery] DateTime checkOut)
    {
        if (checkIn >= checkOut)
            return BadRequest(new ErrorResponseDTO { Message = "Check-out date must be after check-in date", Code = "INVALID_DATES" });

        var rooms = await _roomService.GetAvailableRoomsAsync(checkIn, checkOut);
        return Ok(rooms);
    }

    /// <summary>
    /// Create a new room (Admin only)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<RoomDTO>> CreateRoom([FromBody] CreateRoomDTO dto)
    {
        if (string.IsNullOrWhiteSpace(dto.RoomNumber) || string.IsNullOrWhiteSpace(dto.Type))
            return BadRequest(new ErrorResponseDTO { Message = "Room number and type are required", Code = "INVALID_INPUT" });

        var room = await _roomService.CreateRoomAsync(dto);
        if (room == null)
            return BadRequest(new ErrorResponseDTO { Message = "Room number already exists", Code = "DUPLICATE_ROOM" });

        return CreatedAtAction(nameof(GetRoomById), new { id = room.Id }, room);
    }

    /// <summary>
    /// Update room details (Admin only)
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<RoomDTO>> UpdateRoom(int id, [FromBody] UpdateRoomDTO dto)
    {
        var room = await _roomService.UpdateRoomAsync(id, dto);
        if (room == null)
            return NotFound(new ErrorResponseDTO { Message = "Room not found", Code = "NOT_FOUND" });

        return Ok(room);
    }

    /// <summary>
    /// Delete a room (Admin only)
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteRoom(int id)
    {
        var success = await _roomService.DeleteRoomAsync(id);
        if (!success)
            return NotFound(new ErrorResponseDTO { Message = "Room not found", Code = "NOT_FOUND" });

        return NoContent();
    }
}
