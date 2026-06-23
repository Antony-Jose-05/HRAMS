using HotelBackend.Data;
using HotelBackend.Helpers;
using HotelBackend.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: true);

// ============================================
// DATABASE CONFIGURATION
// ============================================
// Get database connection string from appsettings.json
// If not found, use default: localhost, database: hotel_management, user: root, password: Root@1234
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
                       ?? "server=localhost;port=3306;database=hotel_management;user=root;password=Root@1234;";

// Register AppDbContext with MySQL database
// This tells .NET to use MySQL (via Pomelo) for database operations
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, new MySqlServerVersion(new Version(8, 0, 33)), mySqlOptions =>
        mySqlOptions.EnableRetryOnFailure() // Automatically retry failed queries
    )
);

// ============================================
// JWT AUTHENTICATION SETUP
// ============================================
// JWT (JSON Web Token) is used for secure admin authentication
// Read JWT settings from appsettings.json
var jwtSecret = builder.Configuration["Jwt:Secret"] ?? "staydesk-dev-secret-key-change-before-production";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "StaydeskBackendAPI";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "StaydeskAdminApp";

// Configure JWT Bearer authentication
// This validates tokens sent by the Flutter app in the Authorization header
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = true,
            ValidAudience = jwtAudience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero // Don't allow expired tokens
        };
    });

// ============================================
// CORS CONFIGURATION
// ============================================
// CORS (Cross-Origin Resource Sharing) allows Flutter app to call this API
// Without CORS, browsers/apps on different hosts will get blocked
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", corsPolicyBuilder =>
    {
        corsPolicyBuilder
            .AllowAnyOrigin()  // Allow any origin (Flutter web uses a varying port)
            .AllowAnyMethod()  // Allow GET, POST, PUT, DELETE, etc.
            .AllowAnyHeader(); // Allow any headers from client
    });
});

// ============================================
// DEPENDENCY INJECTION
// ============================================
// Register services so controllers can use them
// These are created once per request (.AddScoped)
builder.Services.AddScoped<AuthService>(); // Handles admin login/registration
builder.Services.AddScoped<RoomService>(); // Handles room operations
builder.Services.AddScoped<BookingService>(); // Handles booking operations

// Add API routing and Swagger (API documentation)
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer(); // For Swagger API Explorer
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "staydesk API",
        Version = "v1",
        Description = "Admin API for room inventory, bookings, and dashboard statistics."
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header using the Bearer scheme."
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// ============================================
// MIDDLEWARE CONFIGURATION
// ============================================
// Order matters! Middleware is executed in order

// Enable Swagger UI in development (access at /swagger)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Enable CORS - must come before authentication
app.UseCors("AllowFlutterApp");

// Enable JWT authentication
app.UseAuthentication();

// Enable authorization
app.UseAuthorization();

// Map all controller routes
app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "ok", service = "staydesk-api" }));

// ============================================
// DATABASE SEEDING
// ============================================
// Seed initial data if database is empty
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

    await context.Database.MigrateAsync();

    var seeded = false;

    if (!await context.Admins.AnyAsync())
    {
        context.Admins.AddRange(
            new Admin { Username = "admin", PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123") },
            new Admin { Username = "demo", PasswordHash = BCrypt.Net.BCrypt.HashPassword("demo123") },
            new Admin { Username = "manager", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass123") }
        );

        seeded = true;
    }

    if (!await context.Rooms.AnyAsync())
    {
        context.Rooms.AddRange(
            new Room { RoomNumber = "101", Type = "Single", Price = 50, Floor = 1, Status = "Available" },
            new Room { RoomNumber = "102", Type = "Double", Price = 75, Floor = 1, Status = "Available" },
            new Room { RoomNumber = "103", Type = "Deluxe", Price = 120, Floor = 1, Status = "Available" },
            new Room { RoomNumber = "201", Type = "Single", Price = 50, Floor = 2, Status = "Available" },
            new Room { RoomNumber = "202", Type = "Suite", Price = 150, Floor = 2, Status = "Occupied" },
            new Room { RoomNumber = "203", Type = "Double", Price = 75, Floor = 2, Status = "Available" }
        );

        seeded = true;
    }

    if (seeded)
    {
        await context.SaveChangesAsync();
        Console.WriteLine("Staydesk database seeded with sample data.");
    }
}

// Start the server
app.Run();
