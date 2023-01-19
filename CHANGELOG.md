## 2023.1.17 (January 17, 2023)

NEW
+ [Multiple editor users working on the same map](https://docs.carto.com/whats-new#multiple-editor-users-working-on-the-same-map)
+ [Builder SQL Analyses available for PostgreSQL connections](https://docs.carto.com/whats-new/q4-2022#builder-sql-analyses-available-for-postgresql-connections)
+ Auto provision workload identity connection [Docs](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#workload-identity-bigquery-connection)

IMPROVEMENTS
+ Redshift connection pool handling
+ Tileset instantiation cache

## 2023.1.3 (January 03, 2023)

IMPROVEMENTS
+ [Additional options to configure the creation of isolines in the Analytics Toolbox](https://docs.carto.com/whats-new/additional-options-isolines/)
+ [Importing geospatial files into PostgreSQL databases through CARTO Workspace](https://docs.carto.com/whats-new/imports-postgresql/)
+ [Improvements for Google BigQuery connections: re-connect and billing project](https://docs.carto.com/whats-new/fixes-for-bigquery-connections/)

## 2022.12.14 (December 14, 2022)

NEW

+ [Resolution selector and aggregation methods for categorical data in spatial index layers](https://docs.carto.com/whats-new/resolution-selector-category-aggregation-spatial-index-layers/)
+ [Logarithmic scales in Builder](https://docs.carto.com/whats-new/logarithmic-scales-in-builder/)

IMPROVEMENTS

+ [Geocoding, Isolines and Tokens quotas now available for tracking in Workspace](https://docs.carto.com/whats-new/2022-added-quotas-in-settings-section/)
+ Show owner's email in Map & Connection cards
+ Google basemaps improvements

FIXES
+ Fix dynamic tiling and columns with lower case letters in Snowflake 
+ Container stability. Some containers were dying with unhandled exceptions.
+ Reduce memory usage of containers
+ Critical security fixes (SQL injection)
+ Postgres connection pool handling

NEW COMPONENT:
+ Notifier. The compose file adds a new container to the installation

## 2022.10.18 (October 18, 2022)
IMPROVEMENTS

+ New and improved login and signup https://docs.carto.com/whats-new/new-login-signup-redesign/
+ Improvements to caching strategy
+ Improvements to point data tiles
+ Added unique ID property selector for widgets on tiled sources
+ Fixed incorrect counting on widgets from tiled sources
+ Fix dynamic tiling in PostgreSQL with tables with capital letters in name
+ Spatial index tiles in binary format by default
+ Support for Databricks SQL Warehouses connections
+ Updated base Docker images with security fixes
+ Use a connection pool for Postgres
+ K8: TLS offload in AWS LoadBalancer
+ K8: Increase min instances of workspace-api and maps-api
+ Create tileset options: Spatial Index and aggragations
+ Other bugs fixes and minor improvements

## 2022.9.2 (September 02, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.19-2 (August 19, 2022)
IMPROVEMENTS
+ Support for Databricks SQL Warehouse connections
+ Support for views in PostgreSQL
+ Bugs Fixing and minor improvements

KNOWN ISSUES
+ GeoParquet import for uploaded files not working
+ Legends in published maps not working
+ Unexpected hover pop-up appears in public maps

## 2022.8.15 (August 15, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.11-8 (August 11, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.11-7 (August 11, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.11-6 (August 11, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.10 (August 10, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.9 (August 09, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.8.1 (August 01, 2022)
IMPROVEMENTS
+ New Range widget in Builder
+ Renaming of data sources in Builder
+ Maps API support for parameterized queries
+ Import API support for GeoParquet files
+ Bugs Fixing and minor improvements

## 2022.7.20 (July 20, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.7.15-2 (July 15, 2022)
IMPROVEMENTS
+ New Data Explorer section
+ CARTOColors available in Builder
+ Custom HTML Popups
+ Bugs Fixing and minor improvements

## 2022.7.5-1 (July 05, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.7.5 (July 05, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.7.4 (July 04, 2022)
IMPROVEMENTS
+ Support for H3 and Quadbin data sources in APIs and Builder
+ Bugs Fixing and minor improvements

## 2022.7.1 (July 01, 2022)
IMPROVEMENTS
+ Dynamic Tilling Queries
+ Bugs Fixing and minor improvements

## 2022.6.30 (June 30, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements
+ New Pop-ups in Builder

## 2022.6.29 (June 29, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements
+ Added partner tag to queries in BigQuery

## 2022.6.24-2 (June 24, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements
+ BUILDER - Visibility by zoom level control for layers

## 2022.6.24-1 (June 24, 2022)
IMPROVEMENTS
+ Bugs Fixing and minor improvements

## 2022.6.23 (June 23, 2022)
IMPROVEMENTS:
- Bugs fixing and minor improvements

## 2022.6.21 (June 21, 2022)
IMPROVEMENTS:
- Bugs fixing and minor improvements
