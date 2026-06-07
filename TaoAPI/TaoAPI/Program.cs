using Microsoft.EntityFrameworkCore;
using TaoAPI.Entities; // Thay bằng tên Project + thư mục chứa Entities của bạn

var builder = WebApplication.CreateBuilder(args);

// 1. Lấy chuỗi kết nối từ appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// 2. Đăng ký DbContext (Kết nối SQL Server)
builder.Services.AddDbContext<MobileAppContext>(options =>
    options.UseSqlServer(connectionString));

// 3. Cấu hình CORS (Để Flutter có thể truy cập được API)
builder.Services.AddCors(options => {
    options.AddPolicy("AllowAll", policy => {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// 4. Kích hoạt CORS (Phải đặt trước MapControllers)
app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();