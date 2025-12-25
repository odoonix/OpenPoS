# Certificates

By default, system generate self signed certificates if 
does not exist.



## Setup Custome Certificates

Replace your keys with following files:


*. server.key
*. server.crt

## Generate Custom Self-Signed Certificates


.. code-block:: bash

    openssl req -x509 -nodes -days 3650 \
        -newkey rsa:2048 \
        -keyout "server.key" \
        -out "server.crt" \
        -subj "/C=IR/ST=Local/L=Local/O=Internal/CN=localhost"