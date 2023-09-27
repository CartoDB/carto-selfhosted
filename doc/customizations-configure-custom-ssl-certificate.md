#### Custom SSL certificate

By default CARTO Self Hosted will generate and use a self-signed certificate if you don't provide it with your own certificate.

**Prerequisites**

- A `.crt` file with your custom domain x509 certificate.
- A `.key` file with your custom domain private key.

**Configuration**

1. Create a `certs` folder in the current directory (`carto-selfhosted`).

2. Copy your `<cert>.crt` and `<cert>.key` files in the `certs` folders (the files must be directly accesible from the server, i.e.: not protected with password and with the proper permissions).

3. Modify the following vars in the `customer.env` file:

   ```diff
   - # ROUTER_SSL_AUTOGENERATE= <1 to enable | 0 to disable>
   - # ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
   - # ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
   + ROUTER_SSL_AUTOGENERATE=0
   + ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
   + ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
   ```

   > Remember to replace the `<cert>` value above with the correct file name.