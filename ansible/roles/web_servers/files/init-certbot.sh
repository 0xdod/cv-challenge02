#!/bin/bash

# domains=(damilola.chickenkiller.com www.damilola.chickenkiller.com db.damilola.chickenkiller.com)
domains=(damilola.jumpingcrab.com www.damilola.jumpingcrab.com db.damilola.jumpingcrab.com)
email="damiloladolor+certbot@gmail.com"
rsa_key_size=4096
data_path="./certbot"
base_path="~/app"

cd "$base_path"

# Create necessary directories
mkdir -p "$data_path/conf" "$data_path/www"

# Check if certificate exists
if [ -d "$data_path/conf/live/${domains[0]}" ]; then
  echo "Existing certificate found. Skipping certificate creation."
  exit 0
fi

echo "### Starting nginx for certbot..."
docker-compose up -d nginx

certbot_domains=()

for domain in "${domains[@]}"; do
    certbot_domains+=("-d" "$domain")
done


echo "### Requesting Let's Encrypt certificate..."
docker-compose run --rm certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email "$email" \
  --agree-tos \
  --no-eff-email \
  --rsa-key-size "$rsa_key_size" \
  "${certbot_domains[@]}"

if [ $? -ne 0 ]; then
  echo "Failed to create certificate."
  exit 1
fi

if [ ! -d "conf.d.bak" ]; then
  sudo cp -r conf.d conf.d.bak
fi


if [ -d "$data_path/conf/live/${domains[0]}" ]; then
  echo "Certificate found. Updating new certificates."
  
  for file in conf.d/*.ssl; do
    sudo rm -- "${file%.ssl}" 
    sudo mv -- "$file" "${file%.ssl}"
  done

fi


echo "### Reloading nginx..."
docker-compose exec nginx nginx -s reload

