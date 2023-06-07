# Whitelisted domains

In case you are setting up some firewall to control the outgoing connections from CARTO Self Hosted, the following
domains needs to be accepted:

## General setup

| URL |
|---|
| auth.carto.com |
| bigquery.googleapis.com |
| cloudresourcemanager.googleapis.com |
| gcr.io |
| iamcredentials.googleapis.com |
| logging.googleapis.com |
| pubsub.googleapis.com |
| storage.googleapis.com |
| tools.google.com |
| www.googleapis.com |

## Datawarehouses

### Snowflake

| URL |
|---|
| *.snowflakecomputing.com |

## Custom Geocoding configurations

### Tomtom geocoding
| URL |
|---|
| api.tomtom.com |

### Mapbox geocoding

| URL |
|---|
| api.mapbox.com |

### Here geocoding and isolines

| URL |
|---|
| isoline.router.hereapi.com |

### Google Maps geocoding and basemaps

| URL |
|---|
| maps.googleapis.com |

## Custom external dabases

### Google Cloud SQL

| URL |
|---|
| sqladmin.googleapis.com |

## Custom Buckets

### AWS S3 buckets

| URL |
|---|
|*.amazonaws.com (or your full bucket URLs) |

### Azure Blob Storage

| URL |
|---|
| *.blob.core.windows.net  (or your full bucket URLs) |

## BigQuery Oauth connections

| URL |
|---|
| oauth2.googleapis.com |
