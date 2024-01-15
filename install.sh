#!/usr/bin/env bash

# Users should use install-nix-action if they want to customise how Nix is installed.

set -euo pipefail

if ! type -p nix &>/dev/null ; then
    env INPUT_EXTRA_NIX_CONFIG= \
        INPUT_INSTALL_OPTIONS= \
        INPUT_INSTALL_URL= \
        INPUT_NIX_PATH="nixpkgs=channel:nixos-unstable" \
        INPUT_ENABLE_KVM=true \
        "$(dirname "$0")"/install-nix-action/install-nix.sh
    # Make the installed Nix immediately available here
    source "$GITHUB_ENV"
    while IFS= read -r dir; do PATH="$dir:$PATH"; done < "$GITHUB_PATH"
fi

echo "::group::Configuring build cache and installing Emacs"
nix profile install --accept-flake-config "github:purcell/nix-emacs-ci#emacs-${INPUT_VERSION/./-}"
echo "::endgroup::"
