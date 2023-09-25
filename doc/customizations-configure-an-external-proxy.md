### External proxy

#### Important notes

:warning: Please consider the following important notes regarding the proxy configuration:

- CARTO self-hosted does not install any proxy component, instead it supports connecting to an existing proxy software deployed by the customer.

- CARTO Self-hosted supports both **HTTP** and **HTTPS** proxies.

- At the moment, password authentication is not supported for the proxy connection.

- [Importing data](https://docs.carto.com/carto-user-manual/data-explorer/importing-data) using an **HTTPS Proxy configured with a certificate signed by a Custom CA** currently has some limitations. Please, contact CARTO Support for this use case.
  - :information_source: Please check [Proxy HTTPS](#proxy-https) to understand the difference between a **custom CA** and a **well known CA**.

#### Configuration

CARTO self-hosted provides support for operating behind an HTTP or HTTPS proxy. The proxy acts as a gateway, enabling CARTO self-hosted components to establish connections with essential external services like Google APIs, Mapbox, and others.

A comprehensive list of domains that must be whitelisted by the proxy for the proper functioning of CARTO self-hosted can be found [here](../proxy/config/whitelisted_domains.md). The list includes domains for the essential core services of CARTO self-hosted, as well as additional optional domains that should be enabled to access specific features.

In order to enable this feature, set the following environment variables (:warning: both uppercase and lowercase variables) in your `.env` file, depending on the protocol your proxy uses.

##### Proxy HTTP

- `HTTP_PROXY` (mandatory): Proxy connection string, consisting of `http://<hostname>:<port>`.
- `HTTPS_PROXY` (mandatory): Same as `HTTP_PROXY`.
- `GRPC_PROXY` (mandatory): Same as `HTTP_PROXY`.
- `NO_PROXY` (optional): Comma-separated list of domains to exclude from proxying.

Example:

```bash
HTTP_PROXY="http://my-proxy:3128"
http_proxy="http://my-proxy:3128"
HTTPS_PROXY="http://my-proxy:3128"
https_proxy="http://my-proxy:3128"
GRPC_PROXY="http://my-proxy:3128"
grpc_proxy="http://my-proxy:3128"
NO_PROXY="localhost,mega.io,dropbox.com,filestack.com"
no_proxy="localhost,mega.io,dropbox.com,filestack.com"
```

##### Proxy HTTPS

> :warning: Currently, using a Snowflake connection with a Proxy HTTPS is not supported.

- `HTTP_PROXY` (mandatory): Proxy connection string, consisting of `https://<hostname>:<port>`.
- `HTTPS_PROXY` (mandatory): Same as `HTTP_PROXY`.
- `NO_PROXY` (optional): Comma-separated list of domains to exclude from proxying.
- `NODE_EXTRA_CA_CERTS` (optional): Path to the proxy CA certificate.
  - :information_source: Please read carefully the [important notes](#important-notes) to understand the current limitations with **custom CAs**.
  - :information_source: If the proxy certificate is signed by a **custom CA**, such CA must be included here.
  - :information_source: If the proxy certificate is signed by a **well known CA**, there is no need to add it here. **Well known CAs** are usually part of the [ca-certificates package](https://askubuntu.com/questions/857476/what-is-the-use-purpose-of-the-ca-certificates-package)
- `NODE_TLS_REJECT_UNAUTHORIZED` (optional): Specify if CARTO Self-hosted should check if the proxy certificate is valid (`1`) or not (`0`).
  - :information_source: For instance, **self signed certificates** validation must be skipped.

Example:

```bash
HTTP_PROXY="https://my-proxy:3129"
http_proxy="https://my-proxy:3129"
HTTPS_PROXY="https://my-proxy:3129"
https_proxy="https://my-proxy:3129"
NO_PROXY="mega.io,dropbox.com,filestack.com"
no_proxy="mega.io,dropbox.com,filestack.com"
NODE_EXTRA_CA_CERTS=/opt/carto/certs/proxy-ca.crt
NODE_TLS_REJECT_UNAUTHORIZED=0
```

#### Supported datawarehouses

Note that while certain data warehouses can be configured to work with the proxy, **there are others that will inherently bypass it**. Therefore, if you have a restrictive network policy in place, you will need to explicitly allow this egress non-proxied traffic.

| Datawarehouse | Proxy HTTP | Proxy HTTPS | Automatic proxy bypass \*\* |
| ------------- | ---------- | ----------- | --------------------------- |
| BigQuery      | Yes        | Yes         | N/A                         |
| Snowflake     | Yes        | No          | No \*\*\*                   |
| Databricks    | No         | No          | Yes                         |
| Postgres      | No         | No          | Yes                         |
| Redshift      | No         | No          | Yes                         |

> :warning: \*\* There's no need to include the non supported datawarehouses in the `NO_PROXY` environment variable list. CARTO self-hosted components will automatically attempt a direct connection to those datawarehouses, with the exception of **HTTPS Proxy + Snowflake**.

> :warning: \*\*\* If an HTTPS proxy is required in your deployment and you are a Snowflake Warehouse user, you need to explicitly exclude snowflake traffic using the configuration below:

```bash
NO_PROXY=".snowflakecomputing.com" ## Check your Snowflake warehouse URL
no_proxy=".snowflakecomputing.com" ## Check your Snowflake warehouse URL
```