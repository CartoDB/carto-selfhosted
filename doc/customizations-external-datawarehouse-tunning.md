### External Data warehouse tuning

CARTO Self Hosted connects to your data warehouse to perform the analysis with your data. When connecting it with Postgres
or with Redshift it is important to understand and configure the connection pool.

Each node will have a connection pool controlled by the environment variables `MAPS_API_V3_POSTGRES_POOL_SIZE` and
`MAPS_API_V3_REDSHIFT_POOL_SIZE`. The pool is per connection created from CARTO Self Hosted. If each user creates a different
connection, each one will have its own pool. The maximum connections can be calculated with the following formula:

```javascript
max_connections = pool_size * number_connections * number_nodes;
```
