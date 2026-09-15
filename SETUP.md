# One-time setup

These are manual steps only you can do (account creation, secrets, DNS). Claude will not
run `tofu` commands or push infrastructure changes — you run these yourself.

## 1. Hetzner Cloud API token

1. In the Hetzner Cloud Console, open (or create) the project for this site.
2. Go to **Security -> API Tokens** -> generate a new token with **Read & Write** access.
3. Copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and paste the token in:
   ```
   hcloud_token = "<paste token here>"
   ```
   `infra/terraform.tfvars` is gitignored — it will not be committed.

## 2. Provision the VM

From `infra/`:

```sh
cd infra
tofu init
tofu plan
tofu apply
```

Review the plan before typing `yes`. Once applied, note the output:

```sh
tofu output server_ipv4
```

## 3. Point the domain at the VM

In the Hetzner DNS console (the domain is already registered at Hetzner), add an A record:

- **Name**: `@` (and optionally `www`)
- **Type**: `A`
- **Value**: the `server_ipv4` output from step 3

DNS propagation can take a few minutes to a couple of hours. Caddy will automatically
request a TLS certificate once the domain resolves to the VM and ports 80/443 are reachable
— no action needed on your part for that.

## 4. First content deploy

From the repo root:

```sh
./deploy/deploy.sh
```

This syncs `index.html`, `css/`, `js/`, `assets/` to the VM. Run it again any time the
site content changes — it doesn't touch infrastructure, so no `tofu apply` needed.

## Ongoing maintenance

- **Content updates**: `./deploy/deploy.sh` — as often as you like.
- **Infrastructure changes** (resizing the VM, firewall rules, etc.): edit the files in
  `infra/`, then `tofu plan` and `tofu apply` yourself, from your machine.
- **State backups**: state is local only (`infra/terraform.tfstate`, not in git). Run
  `./infra/backup-state.sh` after any `tofu apply` that succeeds. If the state file is
  ever lost, the fallback is manually reimporting resources with `tofu import` — accepted
  tradeoff for skipping the Object Storage base fee.
- **OS security patches**: automatic (`unattended-upgrades`), nothing to do.
- **Major OS upgrades** (roughly every 2 years): manual, not covered by this setup — SSH in
  and run a standard Debian release upgrade when the time comes.
