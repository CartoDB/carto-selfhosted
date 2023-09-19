### Post-installation Checks

In order to verify CARTO Self Hosted was correctly installed and it's functional, we recommend performing the following checks:

1. Check all the containers are up and running:

   ```bash
   docker-compose ps
   ```

   > All containers should be in state `Up`, except for `workspace-migrations` which state should be `Exit 0`, meaning the database migrations finished correctly.

2. Sign in to your Self Hosted, create a user and a new organization.

3. Go to the `Connections` page, in the left-hand menu, create a new connection to one of the available providers.

4. Go to the `Data Explorer` page, click on the `Upload` button right next to the `Connections` panel. Import a dataset from a local file.

5. Go back to the `Maps` page, and create a new map.

6. In this new map, add a new layer from a table using the connection created in step 3.

7. Create a new layer from a SQL Query to the same table. You can use a simple query like:

   ```bash
   SELECT * FROM <dataset_name.table_name> LIMIT 100;
   ```

8. Create a new layer from the dataset imported in step 4.

9. Make the map public, copy the sharing URL and open it in a new incognito window.

10. Go back to the `Maps` page, and verify your map appears there and the map thumbnail represents the latest changes you made to the map.