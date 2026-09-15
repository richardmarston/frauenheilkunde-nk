# Deployment architecture

The site is a static build (HTML/CSS/JS, no build step) served from a single small VM.

## Infrastructure (`infra/`)

Provisioned with OpenTofu, using only the official `hetznercloud/hcloud` provider.

- **VM**: one Hetzner Cloud server, type `cx23`, image `debian-12`, in `fsn1` (Falkenstein).
- **Firewall**: inbound 22 (SSH), 80 (HTTP), 443 (HTTPS) only.
- **SSH key**: a dedicated ed25519 keypair (`infra/.ssh/frauenheilkunde-nk[.pub]`, gitignored),
  registered on the VM via `hcloud_ssh_key` and used by nothing else.
- **Provisioning**: the VM's cloud-init (`infra/cloud-init.yaml.tftpl`) installs Caddy and
  `unattended-upgrades`, and writes the Caddyfile at boot. There's no configuration
  management step after that — the VM is provisioned once via cloud-init, not re-converged.

### State backend

OpenTofu state is kept **local only** (`infra/terraform.tfstate`, gitignored, never
committed) — no remote backend. This was a deliberate cost/risk tradeoff: Hetzner Object
Storage carries a ~€7.72/month base fee (flat, regardless of file size) just to hold a
state file that's a few KB, which isn't proportionate to this project. The accepted risk
is that losing the local state file means manually `tofu import`-ing the VM/firewall/SSH
key back into a fresh state rather than restoring from a locked remote copy.

Mitigation: `infra/backup-state.sh` copies the state file to a timestamped local backup
after each successful apply — cheap insurance against a bad overwrite, without paying for
cloud storage every month.

### DNS

Not managed by OpenTofu. The domain (`frauenheilkunde-nk.at`) is registered at Hetzner, so
DNS is just one A record added manually in the Hetzner console, pointing at the VM's IP
(from `tofu output server_ipv4`). This was a deliberate choice: Hetzner's DNS OpenTofu
provider is a third-party community package (`timohirt/hetznerdns`), not official, and
would need a second API token for a single record that essentially never changes.

## Web server: Caddy

Caddy serves the static files from `/var/www/site` and handles TLS automatically —
it requests and renews a Let's Encrypt certificate for the domain with no extra
configuration, as long as the domain's A record points at the VM and ports 80/443 are
reachable (both true here). The entire site config is the Caddyfile written by cloud-init:

```
frauenheilkunde-nk.at {
  root * /var/www/site
  file_server
  encode gzip
}
```

## OS patching

`unattended-upgrades` is enabled at boot and applies security patches automatically on
its own schedule — no CI or external trigger involved. Major OS version upgrades (e.g.
Debian 12 -> 13, roughly every two years) are the one thing this doesn't cover and need
a manual `apt full-upgrade` / release upgrade when the time comes.

## Content deployment (`deploy/deploy.sh`)

Site content (`index.html`, `css/`, `js/`, `assets/`) is deployed independently of
infrastructure changes, by `rsync`-ing over SSH straight to `/var/www/site` using the
dedicated deploy key. This runs locally, on demand — there is no CI pipeline (see below).

Infrastructure changes (`tofu apply`) are expected to be rare — resizing the VM, changing
firewall rules, etc. — and are run manually, locally, by whoever maintains the project.
`tofu` commands are never run by Claude in this repo (see `.claude`/CLAUDE.md); a human
runs `plan`/`apply` and reviews the output first.

## Why no CI/CD (for now)

GitHub Actions was considered — Hetzner has an OIDC-based short-lived credential
mechanism for the Cloud API (`hetznercloud/tps-action`), avoiding a long-lived Hetzner
API token in CI secrets. It was deferred because: it only covers the Cloud API token
(the Object Storage state-backend credentials would still be a static secret either
way), it adds setup/maintenance overhead disproportionate to a single low-change-frequency
site, and running things locally keeps secrets off a third-party platform entirely. This
can be revisited if deploy frequency or team size grows.
