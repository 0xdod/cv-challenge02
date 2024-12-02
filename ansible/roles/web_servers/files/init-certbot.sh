#!/bin/bash
source .env
domains=("$APP_SERVER_NAME" "www.$APP_SERVER_NAME" "db.$APP_SERVER_NAME")
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
sudo docker-compose up -d nginx

certbot_domains=()

for domain in "${domains[@]}"; do
    certbot_domains+=("-d" "$domain")
done


echo "### Requesting Let's Encrypt certificate..."
sudo docker-compose run --rm certbot certonly --webroot \
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


if [ -d "$data_path/conf/live/${domains[0]}" ]; then
  echo "Certificate found. Updating new certificates."
  
  for file in nginx/conf.d/*.ssl; do
    if [ -f "${file%.ssl}" ]; then
      sudo rm -- "${file%.ssl}"
      sudo rm -- "nginx/templates/$(basename ${file%.ssl}).template"
    fi
    
    sudo mv -- "$file" "${file%.ssl}"
  done

fi


echo "### Reloading nginx..."
sudo docker-compose down nginx

