using HotelBackend.DTOs;
using HotelBackend.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace HotelBackend.Controllers;

[ApiController]
[Route("api/auth")]
public class AdminController : ControllerBase
{
    private readonly AuthService _authService;

    public AdminController(AuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Admin Login - Returns JWT token
    /// </summary>
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponseDTO>> Login([FromBody] LoginRequestDTO request)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            return BadRequest(new ErrorResponseDTO { Message = "Username and password are required", Code = "INVALID_INPUT" });

        var result = await _authService.LoginAsync(request);

        if (!result.Success)
            return Unauthorized(result);

        return Ok(result);
    }

    /// <summary>
    /// Admin Registration - Returns JWT token
    /// </summary>
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponseDTO>> Register([FromBody] LoginRequestDTO request)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            return BadRequest(new ErrorResponseDTO { Message = "Username and password are required", Code = "INVALID_INPUT" });

        if (request.Password.Length < 6)
            return BadRequest(new ErrorResponseDTO { Message = "Password must be at least 6 characters", Code = "WEAK_PASSWORD" });

        var result = await _authService.RegisterAsync(request);

        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }
}
