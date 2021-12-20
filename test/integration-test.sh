#!/bin/sh

set -e
set -x

# cleanup
docker rm -f kong-lab-ee kong-lab-database kong-lab-echo
docker network rm kong-lab-net || true

## setup
docker pull kong/kong-gateway:2.5.0.0-alpine
docker tag kong/kong-gateway:2.5.0.0-alpine kong-ee

## create network
docker network create kong-lab-net

## start db
docker run -d --name kong-lab-database \
  --network=kong-lab-net \
  -p 5432:5432 \
  -e "POSTGRES_USER=kong" \
  -e "POSTGRES_DB=kong" \
  -e "POSTGRES_PASSWORD=kong" \
  postgres:9.6

while ! docker exec -it kong-lab-database sh -c "pg_isready"; do
  sleep 2
done
sleep 2

## bootstrap db
docker run --rm --network=kong-lab-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-lab-database" \
  -e "KONG_PG_PASSWORD=kong" \
  -e "KONG_PASSWORD=password" \
  kong-ee kong migrations bootstrap

## start kong
docker run -itd --name kong-lab-ee --network=kong-lab-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-lab-database" \
  -e "KONG_PG_PASSWORD=kong" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:8000" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
  -p 8000:8000 \
  -p 8001:8001 \
  kong-ee

while ! curl -f http://localhost:8001; do
  sleep 1
done

# check the status is OK
curl -q http://localhost:8001/status


(cd echo-backend && docker build -t lb/echo .)
docker run --network=kong-lab-net --name kong-lab-echo -itd lb/echo

curl -vi http://localhost:8001/plugins \
  -F "name=pre-function" \
  -F "config.access[1]=@src/mediate.lua" 

curl -i http://localhost:8001/services \
  --data name=lua-testing-svc \
  --data url='http://kong-lab-echo:3000'

curl -i http://localhost:8001/services/lua-testing-svc/routes \
  --data paths[]=/ \
  --data name=lua-testing-route

# run a simple test
if [ "$(curl -s http://localhost:8000/foo/1)" == "/1" ]; then
  echo "Tests passed"
else
  echo "Tests failed"
fi
