#!/bin/sh
# Syncs the static site to the VM. Run from the repo root or anywhere;
# paths below are relative to this script's location.
set -eu

cd "$(dirname "$0")/.."

SERVER_IP="$(cd infra && tofu output -raw server_ipv4)"
SSH_KEY="infra/.ssh/frauenheilkunde-nk"

rsync -avz --delete \
  -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new" \
  index.html css js assets \
  "root@$SERVER_IP:/var/www/site/"

echo "Deployed to $SERVER_IP"
