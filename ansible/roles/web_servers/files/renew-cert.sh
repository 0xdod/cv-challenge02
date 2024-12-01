#!/bin/bash
cd /home/ubuntu/app

docker-compose run --rm certbot renew
docker-compose exec nginx nginx -s reload

