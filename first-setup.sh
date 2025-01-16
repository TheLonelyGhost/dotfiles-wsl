#!/usr/bin/env bash
set -euo pipefail

DIRNAME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pushd "$DIRNAME" >/dev/null 2>&1

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y build-essential curl git stow

make apply

popd >/dev/null 2>&1
