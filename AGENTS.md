# Niximgs

Container images for well-known applications, built with Nix and published to
GitHub Container Registry. Ensures reproducible and reliable container builds.

**Language:** Nix

## Structure

- `flake.nix` — Main flake exposing all image builds
- Per-application Nix build definitions
- `skaffold.yaml` — Build orchestration

## Available Applications

- **jellyfin** — Media server for managing and streaming media
- **mlflow** — Machine learning lifecycle management platform
- **postgresql** — Advanced open-source relational database
- **radarr** — Movie collection manager for Usenet and BitTorrent
- **sonarr** — TV series collection manager for Usenet and BitTorrent
- **syncthing** — Continuous file synchronization program
- **vaultwarden** — Unofficial Bitwarden compatible server (Rust)
- **whisparr** — Adult movie collection manager

## Usage

```bash
docker pull ghcr.io/shikanime/<application>:latest
```

## Building

```bash
nix develop --impure -c skaffold build
```

## Commit Style

- Plain-text capitalized title, no conventional-commit prefix
- Body with labels: `Design:`, `Related:`, `Closes #`
- Keep Markdown lines wrapped at 80 columns and run `nix fmt` before shipping

## Stack

- 1 commit == 1 PR via ghstack (1 commit is 1 logical atomic change)
- Split work into stacked PRs to keep each PR small and reviewable
- To update a PR: edit files, then `jj squash` (or `git commit --amend`) into the
  **target commit** of the stack — the one that PR represents
- Resubmit with `ghstack` after squashing
- `ghstack land` on the head PR to land the entire stack
- Never `gh pr merge` (creates poisoned commits)
- Never force-push ghstack branches

## Protect `main`

- Require 1 approving review
- Require linear history (no merge commits)
- Require signed commits
- Squash+rebase merge only

*Always use worktrees when making changes. Test image builds with
`nix build .#<image>` before submitting.*
