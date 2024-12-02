#!/bin/bash
cd /home/ubuntu/app
source .env

sudo docker-compose run --rm certbot renew
sudo docker-compose exec nginx nginx -s reload

