#!/bin/sh
# Copies the local OpenTofu state to a timestamped backup. Run after any
# successful `tofu apply`. State is local-only (no remote backend, see
# DEPLOYMENT.md) so this is the only safety net against a bad overwrite.
set -eu

cd "$(dirname "$0")"

if [ ! -f terraform.tfstate ]; then
  echo "No terraform.tfstate found in infra/ -- nothing to back up." >&2
  exit 1
fi

mkdir -p state-backups
dest="state-backups/terraform.tfstate.$(date +%Y%m%dT%H%M%S)"
cp terraform.tfstate "$dest"
echo "Backed up state to infra/$dest"
