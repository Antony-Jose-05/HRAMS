namespace HotelBackend.Models;

public class Booking
{
    public int Id { get; set; }

    public int RoomId { get; set; }
    public Room? Room { get; set; }

    public string GuestName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;

    public DateTime CheckInDate { get; set; }
    public DateTime CheckOutDate { get; set; }

    // "Reserved", "CheckedIn", "CheckedOut"
    public string Status { get; set; } = "Reserved";
}