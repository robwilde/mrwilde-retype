# MrWilde Retype Deployment

This directory contains all files needed to deploy the MrWilde website with HTTPS support.

## Setup Instructions

### 1. Prerequisites
- Docker and Docker Compose installed on your server
- Domain (mrwilde.dev) pointing to your server's IP
- Ports 80 and 443 open on your server

### 2. Deploy to Server
Copy these files to your server:
```bash
scp -r deploy/ user@your-server:/path/to/deployment/
```

### 3. Configure SSL Certificate
Edit `init-letsencrypt.sh` and replace `robert@mrwilde.com` with your actual email address.

### 4. Initialize SSL Certificates
```bash
cd /path/to/deployment/deploy
./init-letsencrypt.sh
```

### 5. Start Services
```bash
docker-compose up -d
```

### 6. Set Up Certificate Renewal
Add to crontab (run `crontab -e`):
```bash
0 12 * * * /path/to/deployment/deploy/renew-certs.sh
```

## Docker Hub Integration

The image is automatically built and pushed to Docker Hub via GitHub Actions when you push to the repository. The latest code is always pulled from the git repository during the Docker build process.

To manually update the deployed site:
```bash
docker-compose pull
docker-compose up -d
```

## Services

- **mrwilde-website**: Your Retype site (port 8182 internally)
- **nginx-proxy**: SSL termination and reverse proxy (ports 80/443)
- **certbot**: Let's Encrypt certificate management

## Troubleshooting

- Check logs: `docker-compose logs [service-name]`
- Restart services: `docker-compose restart`
- View certificate status: `docker-compose run --rm certbot certificates`

## File Structure
```
deploy/
├── docker-compose.yml    # Main orchestration
├── Dockerfile           # Website image build
├── nginx.conf           # SSL proxy configuration
├── nginx-standalone.conf # Internal nginx config
├── init-letsencrypt.sh  # SSL setup script
├── renew-certs.sh       # SSL renewal script
└── ssl/                 # SSL certificates (auto-generated)
```