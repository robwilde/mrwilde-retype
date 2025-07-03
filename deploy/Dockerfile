FROM nginx:alpine
COPY public/ /usr/share/nginx/html/

# Copy nginx configuration for standalone use
COPY deploy/nginx-standalone.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]