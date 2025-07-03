#!/bin/bash

# Initialize Let's Encrypt certificates for mrwilde.dev

# Set your email and domain
EMAIL="robert@mrwilde.com"  # Replace with your email
DOMAIN="mrwilde.dev"
STAGING=0 # Set to 1 for testing

# Create required directories
mkdir -p ssl/www

# Download recommended TLS parameters
if [ ! -e "ssl/options-ssl-nginx.conf" ] || [ ! -e "ssl/ssl-dhparams.pem" ]; then
  echo "Downloading recommended TLS parameters..."
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > ssl/options-ssl-nginx.conf
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > ssl/ssl-dhparams.pem
fi

# Start nginx first to handle ACME challenge
echo "Starting nginx..."
docker-compose up -d nginx-proxy

# Wait for nginx to be ready
echo "Waiting for nginx to be ready..."
sleep 10

# Request certificates
echo "Requesting SSL certificates..."
if [ $STAGING != "0" ]; then
  echo "Using staging server..."
  docker-compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot \
    --email $EMAIL --agree-tos --no-eff-email --staging \
    -d $DOMAIN -d www.$DOMAIN
else
  docker-compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot \
    --email $EMAIL --agree-tos --no-eff-email \
    -d $DOMAIN -d www.$DOMAIN
fi

# Reload nginx to use new certificates
echo "Reloading nginx..."
docker-compose exec nginx-proxy nginx -s reload

echo "SSL certificates obtained successfully!"
echo "Remember to set up certificate renewal with a cron job."