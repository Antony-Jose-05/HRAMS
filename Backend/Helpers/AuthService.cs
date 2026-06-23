using HotelBackend.Data;
using HotelBackend.DTOs;
using HotelBackend.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
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
    public async Task<LoginResponseDTO> LoginAsync(LoginRequestDTO request)
    {
        var username = request.Username.Trim();
        var password = request.Password.Trim();

        // Find admin by username in database
        var admin = await _context.Admins.FirstOrDefaultAsync(a => a.Username == username);

        // Check if admin exists AND password matches
        if (admin == null || !VerifyPassword(password, admin.PasswordHash))
        {
            return new LoginResponseDTO
            {
                Success = false,
                Message = "Invalid username or password"
            };
        }

        if (NeedsPasswordUpgrade(admin.PasswordHash))
        {
            admin.PasswordHash = HashPassword(password);
            await _context.SaveChangesAsync();
        }

        // Generate JWT token if login successful
        var token = GenerateJwtToken(admin);

        return new LoginResponseDTO
        {
            Success = true,
            Message = "Login successful",
            Token = token,
            Admin = new AdminDTO { Id = admin.Id, Username = admin.Username }
        };
    }

    /// <summary>
    /// Register a new admin account
    /// </summary>
    public async Task<LoginResponseDTO> RegisterAsync(LoginRequestDTO request)
    {
        var username = request.Username.Trim();

        // Check if username already exists
        if (await _context.Admins.AnyAsync(a => a.Username == username))
        {
            return new LoginResponseDTO
            {
                Success = false,
                Message = "Username already exists"
            };
        }

        // Create new admin with a hashed password
        var admin = new Admin
        {
            Username = username,
            PasswordHash = HashPassword(request.Password)
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
        var jwtSecret = _configuration["Jwt:Secret"] ?? "staydesk-dev-secret-key-change-before-production";
        var jwtIssuer = _configuration["Jwt:Issuer"] ?? "StaydeskBackendAPI";
        var jwtAudience = _configuration["Jwt:Audience"] ?? "StaydeskAdminApp";
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
            new Claim(ClaimTypes.Role, "admin") // Admin role
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

    private static bool VerifyPassword(string password, string storedPasswordHash)
    {
        if (string.IsNullOrWhiteSpace(storedPasswordHash))
        {
            return false;
        }

        return IsBcryptHash(storedPasswordHash)
            ? BCrypt.Net.BCrypt.Verify(password, storedPasswordHash)
            : storedPasswordHash == password;
    }

    private static bool NeedsPasswordUpgrade(string storedPasswordHash)
    {
        return !IsBcryptHash(storedPasswordHash);
    }

    private static bool IsBcryptHash(string value)
    {
        return value.StartsWith("$2", StringComparison.Ordinal);
    }

    private static string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }
}
