## How to apply the configurations

Make your changes to the `customer.env` file before starting the installation steps.

> :warning: Anytime you edit the `customer.env` file to change the CARTO configuration you will need to apply it to your installation:
>
> 1. Run the `install.sh` script to update the `.env` file used by Docker Compose.
>
>    `bash install.sh`
>
> 2. Refresh the installation configuration.
>
>    `docker-compose down && docker-compose up -d`