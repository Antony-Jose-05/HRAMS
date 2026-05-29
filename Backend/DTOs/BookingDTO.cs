namespace HotelBackend.DTOs;

public class BookingDTO
{
    public int Id { get; set; }
    public int RoomId { get; set; }
    public string GuestName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public DateTime CheckInDate { get; set; }
    public DateTime CheckOutDate { get; set; }
    public string Status { get; set; } = "Reserved"; // Reserved, CheckedIn, CheckedOut
    public RoomDTO? Room { get; set; }
}

public class CreateBookingDTO
{
    public int RoomId { get; set; }
    public string GuestName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public DateTime CheckInDate { get; set; }
    public DateTime CheckOutDate { get; set; }
}

public class UpdateBookingDTO
{
    public string? GuestName { get; set; }
    public string? Phone { get; set; }
    public DateTime? CheckInDate { get; set; }
    public DateTime? CheckOutDate { get; set; }
    public string? Status { get; set; }
}
