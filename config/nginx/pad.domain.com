server {
    listen 80;
    listen [::]:80;

    server_name pad.domain.com;

    return 301 https://pad.domain.com$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    location / {
        proxy_pass http://127.0.0.1:9001;

        proxy_set_header Host $host;
        proxy_set_header Connection       $http_connection;
        proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme         $scheme;
        proxy_buffering                   off;

        auth_basic           "Welcome";
        auth_basic_user_file /etc/nginx/sites-available/.htpassword_pad;
    }

    include snippets/ssl.conf;
    include /etc/nginx/snippets/letsencrypt.conf;

    server_name pad.domain.com;

    ssl_certificate /etc/letsencrypt/live/pad.domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pad.domain.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/pad.domain.com/fullchain.pem;

    access_log /var/log/nginx/pad.domain.com.access.log;
    error_log /var/log/nginx/pad.domain.com.error.log;
}
