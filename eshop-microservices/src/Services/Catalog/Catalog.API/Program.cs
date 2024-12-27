var builder = WebApplication.CreateBuilder(args);

// add sevices to the container


var app = builder.Build();

// configure the Http request pipline.

app.Run();
