namespace HotelBackend.Models;

public class Room
{
    public int Id { get; set; }
    public string RoomNumber { get; set; } = string.Empty; // "101"
    public string Type { get; set; } = string.Empty;       // "Deluxe"
    public decimal Price { get; set; }                     // 1200
    public int Floor { get; set; }                         // 1
    public string Status { get; set; } = "Available";     // "Available", "Occupied", "Reserved"
}