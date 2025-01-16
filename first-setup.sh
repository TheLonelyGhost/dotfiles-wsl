#!/usr/bin/env bash
set -euo pipefail

DIRNAME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if grep -ve '^#' /etc/apt/sources.list | grep -qFe 'bookworm'; then
  printf 'INFO: Debian bookworm has been detected. This contains packages that are too out of date to work with these dotfiles. Upgrading to the next distribution version: trixie\n' >&2
  sudo sed -i'.bak' -e's/bookworm/trixie/g;/trixie-backports/d;/trixie-updates/d' /etc/apt/sources.list

  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get full-upgrade -y
else
  sudo apt-get update -y
  sudo apt-get upgrade -y
fi

sudo apt-get install -y build-essential curl git stow

pushd "$DIRNAME" >/dev/null 2>&1

make apply

popd >/dev/null 2>&1
