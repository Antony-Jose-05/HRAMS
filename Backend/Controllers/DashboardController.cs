using HotelBackend.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HotelBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly AppDbContext _context;

    public DashboardController(AppDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Get dashboard statistics
    /// </summary>
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
    {
        var totalRooms = await _context.Rooms.CountAsync();
        var availableRooms = await _context.Rooms.CountAsync(r => r.Status == "Available");
        var occupiedRooms = await _context.Rooms.CountAsync(r => r.Status == "Occupied");
        
        var totalBookings = await _context.Bookings.CountAsync();
        var activeBookings = await _context.Bookings.CountAsync(b => b.Status != "CheckedOut");

        return Ok(new
        {
            TotalRooms = totalRooms,
            AvailableRooms = availableRooms,
            OccupiedRooms = occupiedRooms,
            TotalBookings = totalBookings,
            ActiveBookings = activeBookings
        });
    }
}
