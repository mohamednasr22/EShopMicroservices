using Microsoft.Extensions.Configuration;

var builder = WebApplication.CreateBuilder(args);

// add sevices to the container

var assembly = typeof(Program).Assembly;
builder.Services.AddMediatR(config =>
{
    config.RegisterServicesFromAssembly(assembly);
    //config.AddOpenBehavior(typeof(ValidationBehavior<,>));
    //config.AddOpenBehavior(typeof(LoggingBehavior<,>));
});
builder.Services.AddCarter();
builder.Services.AddMarten(opts =>
{
    opts.Connection(builder.
    Configuration.GetConnectionString("CatalogConnection")!);
}).UseLightweightSessions(); 

var app = builder.Build();

// configure the Http request pipline.

app.Run();
