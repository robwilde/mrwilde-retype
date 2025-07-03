#!/bin/bash

# Renew Let's Encrypt certificates and reload nginx

cd "$(dirname "$0")"

echo "Renewing certificates..."
docker-compose run --rm certbot renew

echo "Reloading nginx..."
docker-compose exec nginx-proxy nginx -s reload

echo "Certificate renewal complete!"