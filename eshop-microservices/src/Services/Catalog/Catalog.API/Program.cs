using Microsoft.Extensions.Configuration;
using Carter;
using MediatR;
using Marten;
using Catalog.API.Products.CreateProduct;
using BuildingBlocks.Behaviors;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCarter();

// Add services to the container
var assembly = typeof(Program).Assembly;
builder.Services.AddMediatR(config =>
{
    config.RegisterServicesFromAssembly(assembly);
    config.AddOpenBehavior(typeof(ValidationBehavior<,>));
    //config.AddOpenBehavior(typeof(LoggingBehavior<,>));
});

builder.Services.AddValidatorsFromAssembly(assembly);
//builder.Services.AddTransient<IValidator<CreateProductCommand>, CreateProductCommandValidator>();

builder.Services.AddMarten(opts =>
{
    opts.Connection(builder.Configuration.GetConnectionString("CatalogConnection")!);
}).UseLightweightSessions();

var app = builder.Build();

// Configure the HTTP request pipeline
app.MapCarter(); // THIS LINE IS MISSING IN YOUR ORIGINAL CODE

app.Run();