﻿

namespace Catalog.API.Products.GetProductById
{

    public record GetProductByIdQuery(Guid Id) : IQuery<GetProductByIdResult>;
    public record GetProductByIdResult(Product Product);//: IQuery<GetProductByIdResult>;

    internal class GetProductByIdQueryHandler(IDocumentSession session , ILogger<GetProductByIdQueryHandler> log) : IQueryHandler<GetProductByIdQuery, GetProductByIdResult>
    {
        public async Task<GetProductByIdResult> Handle(GetProductByIdQuery query, CancellationToken cancellationToken)
        {
            log.LogInformation("GetProductByIdQueryHandler.Handle");
            Product product = null;//= await session.LoadAsync<Product>(query.Id, cancellationToken);
            if (product is null)
            {
                throw new ProductNotFoundException(query.Id);
            }
            return new GetProductByIdResult(product);
        }
    }
    
}
