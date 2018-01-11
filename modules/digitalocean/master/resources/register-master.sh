#!/bin/bash
set -ex
set -o pipefail

register_floating_ip() {
  curl --fail -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${1}" -d \
  "{\"type\": \"assign\", \"droplet_id\": ${2}}" \
  "https://api.digitalocean.com/v2/floating_ips/${3}/actions"
}

register_lb() {
  curl --fail -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${1}" \
  -d "{\"droplet_ids\": [${2}]}" "https://api.digitalocean.com/v2/load_balancers/${3}/droplets"
}

until register_floating_ip $1 $2 $3; do
  echo "failed to register droplet with DO floating IP; retrying in 5 seconds"
  sleep 5
done

until register_lb $1 $2 $4; do
  echo "failed to register droplet with DO load balancer; retrying in 5 seconds"
  sleep 5
done
