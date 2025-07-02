#!/bin/bash

# Check if certificates already exist
if [ ! -f /etc/letsencrypt/live/mrwilde.dev/fullchain.pem ]; then
    echo "Obtaining SSL certificates for mrwilde.dev..."
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email robert@mrwilde.com \
        --agree-tos \
        --no-eff-email \
        -d mrwilde.dev \
        -d www.mrwilde.dev

    if [ $? -eq 0 ]; then
        echo "SSL certificates obtained successfully!"
    else
        echo "Failed to obtain SSL certificates"
        exit 1
    fi
else
    echo "SSL certificates already exist"
fi

# Start renewal daemon
echo "Starting certificate renewal daemon..."
while true; do
    sleep 12h
    echo "Checking for certificate renewal..."
    certbot renew --quiet
done