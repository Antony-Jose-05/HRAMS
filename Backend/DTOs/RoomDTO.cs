namespace HotelBackend.DTOs;

public class RoomDTO
{
    public int Id { get; set; }
    public string RoomNumber { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Floor { get; set; }
    public string Status { get; set; } = "Available"; // Available, Occupied, Reserved
}

public class CreateRoomDTO
{
    public string RoomNumber { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Floor { get; set; }
}

public class UpdateRoomDTO
{
    public string? Type { get; set; }
    public decimal? Price { get; set; }
    public int? Floor { get; set; }
}
