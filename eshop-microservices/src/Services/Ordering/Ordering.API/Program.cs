using Ordering.Application;
using Ordering.Infrastructure;
//using Ordering.Application;


namespace Ordering.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Services
               .AddApplicationServices(builder.Configuration)
               .AddInfrastructureServices(builder.Configuration)
               .AddApiServices(builder.Configuration);


            var app = builder.Build();
            // Add services to the container.
           
            app.Run();
        }
    }
}
