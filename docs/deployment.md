# Deployment

## Website
Static files are stored in `site/` and served by Nginx from
`/var/www/devops-site`.

## HTTPS
The website is available at `https://devops.local`.
The development server uses a self-signed TLS certificate.

HTTP requests are redirected to HTTPS.

## Deployment script
- `scripts/deploy.sh --dry-run` previews synchronization.
- `scripts/deploy.sh` deploys the website.
- The script requires a clean Git working tree and SSH key authentication.
- Files receive permissions 644; directories receive permissions 755.
- The `--delete` option removes server files that are absent from `site/`.

## Logs
- Access log: `/var/log/nginx/devops-site.access.log`
- Error log: `/var/log/nginx/devops-site.error.log`
