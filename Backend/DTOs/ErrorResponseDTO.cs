namespace HotelBackend.DTOs;

public class ErrorResponseDTO
{
    public bool Success { get; set; } = false;
    public string Message { get; set; } = string.Empty;
    public string? Code { get; set; }
}
