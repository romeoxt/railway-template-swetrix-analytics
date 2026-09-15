#!/bin/sh

PORT="${PORT:-8080}"
API_HOST="${SWETRIX_API_HOST:?Set SWETRIX_API_HOST}"
FE_HOST="${SWETRIX_FE_HOST:?Set SWETRIX_FE_HOST}"
API_PORT="${SWETRIX_API_PORT:-5005}"
FE_PORT="${SWETRIX_FE_PORT:-8080}"

cat > /etc/nginx/conf.d/default.conf <<EOF
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  "" close;
}

server {
  listen ${PORT};
  server_name _;

  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;

  location /backend/ {
    proxy_pass http://${API_HOST}:${API_PORT}/;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location / {
    proxy_pass http://${FE_HOST}:${FE_PORT};
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF

exec nginx -g 'daemon off;'
