#!/usr/bin/env bash

# This is a cut-down version of https://github.com/cachix/install-nix-action/blob/master/lib/install-nix.sh
# Users should use install-nix-action if they want to customise how Nix is installed.

set -euo pipefail

if ! type -p nix &>/dev/null ; then
    # Configure Nix
    add_config() {
        echo "$1" | tee -a /tmp/nix.conf >/dev/null
    }
    # Set jobs to number of cores
    add_config "max-jobs = auto"
    if [[ $OSTYPE =~ darwin ]]; then
        add_config "ssl-cert-file = /etc/ssl/cert.pem"
    fi
    # Allow binary caches for user
    add_config "trusted-users = root ${USER:-}"
    # Add github access token
    if [[ -n "${INPUT_GITHUB_ACCESS_TOKEN:-}" ]]; then
        add_config "access-tokens = github.com=$INPUT_GITHUB_ACCESS_TOKEN"
    elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
        add_config "access-tokens = github.com=$GITHUB_TOKEN"
    fi
    # Append extra nix configuration if provided

    # Nix installer flags
    installer_options=(
        --no-channel-add
        --darwin-use-unencrypted-nix-store-volume
        --nix-extra-conf-file /tmp/nix.conf
    )

    # only use the nix-daemon settings if on darwin (which get ignored) or systemd is supported
    if [[ $OSTYPE =~ darwin || -e /run/systemd/system ]]; then
        installer_options+=(
            --daemon
            --daemon-user-count `python -c 'import multiprocessing as mp; print(mp.cpu_count() * 2)'`
        )
    else
        # "fix" the following error when running nix*
        # error: the group 'nixbld' specified in 'build-users-group' does not exist
        mkdir -m 0755 /etc/nix
        echo "build-users-group =" > /etc/nix/nix.conf
    fi

    echo "installer options: ${installer_options[@]}"
    sh <(curl --retry 5 --retry-connrefused -L "${INPUT_INSTALL_URL:-https://nixos.org/nix/install}") "${installer_options[@]}"

    # Set paths
    echo "/nix/var/nix/profiles/default/bin" >> "$GITHUB_PATH"
    # new path for nix 2.14
    echo "$HOME/.nix-profile/bin" >> "$GITHUB_PATH"

    export NIX_PATH=nixpkgs=channel:nixpkgs-unstable
    echo "NIX_PATH=${NIX_PATH}" >> $GITHUB_ENV
fi

PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
nix-env --quiet -j8 -iA cachix -f https://cachix.org/api/v1/install
cachix use emacs-ci
nix-env -iA "emacs-${INPUT_VERSION/./-}" -f "https://github.com/purcell/nix-emacs-ci/archive/master.tar.gz"

emacs -version
