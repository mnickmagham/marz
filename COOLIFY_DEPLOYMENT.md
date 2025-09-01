# Coolify Deployment Configuration for Marzban VPN Panel

## Environment Variables to Set in Coolify:

### Required Variables:
UVICORN_HOST=0.0.0.0
UVICORN_PORT=8000
SUDO_USERNAME=admin
SUDO_PASSWORD=admin
XRAY_SUBSCRIPTION_URL_PREFIX=https://marz.timelessmovies.sbs
SQLALCHEMY_DATABASE_URL=sqlite:///var/lib/marzban/db.sqlite3

### Optional Variables:
DEBUG=False
DOCS=False
ALLOWED_ORIGINS=https://marz.timelessmovies.sbs,http://marz.timelessmovies.sbs

## Volume Mounts in Coolify:
# /var/lib/marzban - for database and persistent data
# /opt/marzban - for configuration files

## Port Configuration:
# Expose port 8000 (internal container port)
# Map to desired external port in Coolify

## Domain Configuration:
# Set your domain: marz.timelessmovies.sbs
# Enable SSL/TLS termination in Coolify

## Health Check:
# Path: /api/system
# Port: 8000
# Protocol: HTTP

## Notes:
# - The application will automatically create the admin user on first startup
# - Database migrations run automatically on container startup
# - Xray is pre-installed and configured
# - The subscription URL is set to your domain
