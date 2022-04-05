server {
    listen 80;
    listen [::]:80;

    server_name www.domain.com domain.com;

    return 301 https://domain.com$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    root /opt/etherpad/export_static;

    rewrite ^/home.html$ / last;

    location = / {
        auth_basic off;
        allow all;
    }

    location = /main.css {
        auth_basic off;
        allow all;
    }

    location ~ /blog_.+$ {
        auth_basic           "Welcome";
        auth_basic_user_file /etc/nginx/sites-available/.htpassword_www;
    }

    include snippets/ssl.conf;
    include /etc/nginx/snippets/letsencrypt.conf;

    server_name domain.com www.domain.com;

    ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;

    access_log /var/log/nginx/www.domain.com.access.log;
    error_log /var/log/nginx/www.domain.com.error.log;
}
