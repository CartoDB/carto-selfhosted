### External Redis

CARTO comes with an embedded Redis that is not recommended for production installations, we recommend to use your own Redis that lives outside the Docker ecosystem.

Here are some Terraform examples of Redis instances created in different providers:

- [GCP Redis](../examples/terraform/gcp/redis.tf).
- [AWS Redis](../examples/terraform/aws/redis.tf).
- [Azure Redis](../examples/terraform/azure/redis.tf).

**Prerequisites**

- Redis 6 or above.

**Configuration**

1. Comment the local Redis configuration:

   ```diff
   # Configuration for using a local redis, instead of a external one (comment when external redis)
   - LOCAL_REDIS_SCALE=1
   - REDIS_HOST=redis
   - REDIS_PORT=6379
   - REDIS_TLS_ENABLED=false
   + # LOCAL_REDIS_SCALE=1
   + # REDIS_HOST=redis
   + # REDIS_PORT=6379
   + # REDIS_TLS_ENABLED=false
   ```

2. Uncomment the external Redis configuration:

   ```diff
   # Your custom configuration for a external redis (comment when local redis)
   - # LOCAL_REDIS_SCALE=0
   - # REDIS_HOST=<FILL_ME>
   - # REDIS_PORT=<FILL_ME>
   - # REDIS_PASSWORD=<FILL_ME>
   - # REDIS_TLS_ENABLED=true
   # Only applies if Redis TLS certificate it's self signed, read the documentation
   # REDIS_TLS_CA=<FILL_ME>
   + LOCAL_REDIS_SCALE=0
   + REDIS_HOST=<FILL_ME>
   + REDIS_PORT=<FILL_ME>
   + REDIS_PASSWORD=<FILL_ME>
   + REDIS_TLS_ENABLED=true
   ```

3. Replace the `<FILL_ME>` placeholders with the right values.

#### Configure TLS

By default CARTO will try to connect to your Redis without TLS, in case you want to connect via TLS ,you can configure it via `REDIS_TLS_ENABLED` env vars in the `customer.env`file

```bash
REDIS_TLS_ENABLED=true
```

> :warning: In case you are connection to a Redis where the TLS certificate is self signed or from a custom CA you will need to configure the `REDIS_TLS_CA` variable

1. Copy you CA `.crt` file inside `certs` folder. Rename the CA `.crt` file to `redis-tls-ca.crt`.

2. Uncomment the `REDIS_TLS_CA` env var in the `customer.env` file.

   ```diff
   # Only applies if Redis TLS certificate it's selfsigned, read the documentation
   - # REDIS_TLS_CA=/usr/src/certs/redis-tls-ca.crt
   + REDIS_TLS_CA=/usr/src/certs/redis-tls-ca.crt
   ```