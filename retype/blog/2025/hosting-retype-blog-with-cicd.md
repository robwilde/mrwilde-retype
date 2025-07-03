---
author:
    name: Robert Wilde
    avatar: https://en.gravatar.com/userimage/147698178/ba5af134d07fd7ed2f40436cf2c568ce.jpeg
    email: robert@mrwilde.com
description: My experience deploying a Retype blog with Docker, GitHub Actions, and Let's Encrypt on a home server
category: DevOps
tags: [docker, cicd, github-actions, nginx, letsencrypt, retype]
date: 2025-07-03
---

# Hosting my Retype blog with CI/CD - here is my experience getting my Retype blog hosted on my home server with Docker and GitHub actions

Setting up a modern CI/CD pipeline for a static site generator might seem straightforward, but real-world deployment often presents unexpected challenges. Here's my journey deploying a Retype blog with Docker, GitHub Actions, and Let's Encrypt SSL certificates on my home OpenMediaVault server.

## The Vision

I wanted to achieve three key goals:
1. **Linux compatibility**: Update the Dockerfile to use npm instead of .NET SDK
2. **Automatic updates**: Configure Docker to pull from GitHub repository on rebuild
3. **HTTPS support**: Production-ready SSL certificates with Let's Encrypt

## Architecture Overview

The final solution consists of:
- **Multi-stage Docker build** with Node.js and nginx
- **GitHub Actions CI/CD** for automated Docker Hub deployments
- **Let's Encrypt integration** with automatic certificate renewal
- **OpenMediaVault deployment** using docker-compose plugin

## Docker Configuration

### Multi-Stage Dockerfile

The original Dockerfile used .NET SDK, but I needed better Linux compatibility with npm:

```dockerfile
FROM node:18 AS builder
WORKDIR /app
RUN git clone https://github.com/robwilde/mrwilde-retype.git .
RUN npm install -g retypeapp
RUN retype build

FROM nginx:alpine
COPY --from=builder /app/_site /usr/share/nginx/html
COPY deploy/nginx-standalone.conf /etc/nginx/nginx.conf
EXPOSE 80 443
```

This approach:
- Uses Node.js 18 for consistent npm environment
- Clones the repository directly in the container
- Installs Retype globally via npm
- Builds the static site
- Serves with nginx alpine for production

### Nginx Configuration

The nginx config needed to handle both HTTP and HTTPS while supporting Let's Encrypt validation:

```nginx
server {
    listen 80;
    server_name mrwilde.dev www.mrwilde.dev _;
    root /usr/share/nginx/html;
    index index.html;

    # Let's Encrypt challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Serve content normally
    location / {
        try_files $uri $uri/ /index.html;
    }
}

server {
    listen 443 ssl;
    http2 on;
    server_name mrwilde.dev www.mrwilde.dev;
    
    ssl_certificate /etc/letsencrypt/live/mrwilde.dev/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mrwilde.dev/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## GitHub Actions CI/CD Pipeline

Automated builds trigger on every push to the develop branch:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        file: ./deploy/Dockerfile
        push: true
        tags: mrwilde/mrwilde-retype:develop
```

## Docker Compose Orchestration

The docker-compose.yml needed to handle both the web server and certificate management:

```yaml
services:
  mrwilde-website:
    image: mrwilde/mrwilde-retype:develop
    ports:
      - "8280:80"
      - "8444:443"
    volumes:
      - ssl-data:/etc/letsencrypt
      - certbot-data:/var/www/certbot
    restart: unless-stopped
    container_name: mrwilde-site

  certbot:
    image: certbot/certbot
    container_name: certbot
    volumes:
      - ssl-data:/etc/letsencrypt
      - certbot-data:/var/www/certbot
    dns:
      - 1.1.1.1
      - 8.8.8.8
    extra_hosts:
      - "mrwilde.dev:144.6.123.191"
      - "www.mrwilde.dev:144.6.123.191"
    command: [
      "sh", "-c",
      "if [ ! -f /etc/letsencrypt/live/mrwilde.dev/fullchain.pem ]; then certbot certonly --webroot --webroot-path=/var/www/certbot --email robert@mrwilde.com --agree-tos --no-eff-email -d mrwilde.dev -d www.mrwilde.dev; fi && while true; do sleep 12h; certbot renew --quiet; done"
    ]
    restart: unless-stopped

volumes:
  ssl-data:
  certbot-data:
```

## Challenges and Solutions

### 1. Docker Hub Authentication

**Problem**: "push access denied, repository does not exist or may require authorization"

**Solution**: Set up proper GitHub secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`) and ensure the Docker Hub repository name matched exactly.

### 2. Let's Encrypt Validation Timeouts

**Problem**: "Timeout during connect (likely firewall problem)"

**Root Cause**: Even with a static IP, my ISP required explicit requests to open ports 80 and 443.

**Solution**: Contacted ISP to explicitly open these ports, despite having port forwarding configured.

### 3. Port Conflicts

**Problem**: Connection refused errors when accessing the site

**Discovery**: Other containers (Firefly III) were using overlapping ports

**Solution**: Changed from ports `8281:80/8443:443` to `8280:80/8444:443`

### 4. Certificate Chicken-and-Egg Problem

**Problem**: Nginx couldn't start with HTTPS config when no certificates existed, but certbot needed nginx running for validation.

**Solution**: 
1. Initially deploy with only HTTP server block
2. Let certbot generate certificates
3. Re-enable HTTPS server block
4. Restart nginx to load certificates

### 5. DNS Resolution Issues

**Problem**: Certbot was resolving domains to local IP instead of public IP

**Solution**: Added custom DNS servers (`1.1.1.1`, `8.8.8.8`) and explicit host entries in the certbot container.

## Key Learnings

### OpenMediaVault Constraints
Working with OMV's docker-compose plugin meant:
- GUI-only management (no direct file system access)
- Everything must be self-contained in containers
- Limited debugging capabilities compared to traditional Docker setups

### Let's Encrypt Best Practices
- Always test with staging certificates first
- Ensure proper DNS resolution for domain validation
- Use webroot validation for better reliability
- Implement automatic renewal (every 12 hours in our case)

### Docker Multi-Stage Benefits
- Smaller production images (nginx alpine vs full Node.js)
- Separation of build and runtime environments
- Automatic code pulling on each build

## Final Architecture

The deployed solution now provides:
- **HTTP access**: `mrwilde.dev:80` → `8280` (for Let's Encrypt challenges)
- **HTTPS access**: `mrwilde.dev:443` → `8444` (production traffic)
- **Automatic updates**: GitHub push triggers Docker Hub build
- **SSL management**: Production Let's Encrypt certificates with auto-renewal
- **Security headers**: HSTS, XSS protection, and content type enforcement

## Performance and Monitoring

The nginx configuration includes:
- **Gzip compression** for text assets
- **Static asset caching** with 1-year expiration
- **HTTP/2 support** for modern browsers
- **Security headers** for enhanced protection

## Conclusion

What started as a simple static site deployment evolved into a comprehensive CI/CD pipeline with multiple challenging technical hurdles. The key to success was systematic troubleshooting, understanding the constraints of the deployment environment, and building robust automation.

The final solution automatically:
- Pulls code changes from GitHub
- Builds and deploys Docker images
- Maintains SSL certificates
- Serves content with proper security headers

This setup provides a solid foundation for hosting personal projects with professional-grade infrastructure, all running on a home server with enterprise-level automation.

## Resources

- [Retype Documentation](https://retype.com/)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [GitHub Actions Docker Guide](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [OpenMediaVault Docker Compose Plugin](https://github.com/openmediavault/openmediavault-compose)