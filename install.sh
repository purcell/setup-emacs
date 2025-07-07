#!/usr/bin/env bash

# Users should use install-nix-action if they want to customise how Nix is installed.

set -euo pipefail

if ! type -p nix &>/dev/null ; then
    missing_deps=""
    for dep in sudo curl xz; do
      type -p "$dep" || exec missing_deps="$dep $missing_deps"
    done
    if [ -n "$missing_deps" ]; then
      echo "The nix installer will require some programs that are not installed: $missing_deps" >&2
      exit 1
    fi
    env INPUT_EXTRA_NIX_CONFIG= \
        INPUT_INSTALL_OPTIONS= \
        INPUT_INSTALL_URL= \
        INPUT_NIX_PATH="nixpkgs=channel:nixos-unstable" \
        INPUT_ENABLE_KVM=true \
        "$(dirname "$0")"/install-nix.sh
    # Make the installed Nix immediately available here
    source "$GITHUB_ENV"
    while IFS= read -r dir; do PATH="$dir:$PATH"; done < "$GITHUB_PATH"
fi

echo "::group::Configuring build cache and installing Emacs"
nix profile install --accept-flake-config "github:purcell/nix-emacs-ci#emacs-${INPUT_VERSION/./-}"
echo "::endgroup::"
