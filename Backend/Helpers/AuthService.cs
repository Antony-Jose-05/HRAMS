using HotelBackend.Data;
using HotelBackend.DTOs;
using HotelBackend.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace HotelBackend.Helpers;

/// <summary>
/// AuthService handles admin authentication (login and registration)
/// Uses JWT tokens for secure authentication
/// </summary>
public class AuthService
{
    private readonly AppDbContext _context; // Database access
    private readonly IConfiguration _configuration; // Configuration from appsettings.json

    public AuthService(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    /// <summary>
    /// Authenticate admin with username and password
    /// </summary>
    public Task<LoginResponseDTO> LoginAsync(LoginRequestDTO request)
    {
        // Find admin by username in database
        var admin = _context.Admins.FirstOrDefault(a => a.Username == request.Username);

        // Check if admin exists AND password matches
        if (admin == null || admin.Password != request.Password)
        {
            return Task.FromResult(new LoginResponseDTO
            {
                Success = false,
                Message = "Invalid username or password"
            });
        }

        // Generate JWT token if login successful
        var token = GenerateJwtToken(admin);

        return Task.FromResult(new LoginResponseDTO
        {
            Success = true,
            Message = "Login successful",
            Token = token,
            Admin = new AdminDTO { Id = admin.Id, Username = admin.Username }
        });
    }

    /// <summary>
    /// Register a new admin account
    /// </summary>
    public async Task<LoginResponseDTO> RegisterAsync(LoginRequestDTO request)
    {
        // Check if username already exists
        if (_context.Admins.Any(a => a.Username == request.Username))
        {
            return new LoginResponseDTO
            {
                Success = false,
                Message = "Username already exists"
            };
        }

        // Create new admin with plain text password
        var admin = new Admin
        {
            Username = request.Username,
            Password = request.Password
        };

        // Save to database
        _context.Admins.Add(admin);
        await _context.SaveChangesAsync();

        // Generate token for immediate login after registration
        var token = GenerateJwtToken(admin);

        return new LoginResponseDTO
        {
            Success = true,
            Message = "Registration successful",
            Token = token,
            Admin = new AdminDTO { Id = admin.Id, Username = admin.Username }
        };
    }

    /// <summary>
    /// Generate JWT token for authenticated admin
    /// Token contains admin ID, username, and role
    /// </summary>
    private string GenerateJwtToken(Admin admin)
    {
        // Get JWT settings from configuration
        var jwtSecret = _configuration["Jwt:Secret"] ?? "your-super-secret-key-that-is-at-least-32-characters-long-for-HS256";
        var jwtIssuer = _configuration["Jwt:Issuer"] ?? "HotelBackendAPI";
        var jwtAudience = _configuration["Jwt:Audience"] ?? "HotelApp";
        var jwtExpiryMinutes = int.Parse(_configuration["Jwt:ExpiryMinutes"] ?? "60");

        // Create encryption key from secret
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // Add claims (data) to token
        // Claims are pieces of information about the user
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, admin.Id.ToString()), // Admin ID
            new Claim(ClaimTypes.Name, admin.Username), // Admin username
            new Claim("role", "admin") // Admin role
        };

        // Create token with expiration
        var token = new JwtSecurityToken(
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(jwtExpiryMinutes), // Token expires in 60 minutes
            signingCredentials: credentials
        );

        // Convert token to string format to send to client
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
