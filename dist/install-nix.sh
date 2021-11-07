#!/usr/bin/env bash

# This is a cut-down version of https://github.com/cachix/install-nix-action/blob/master/lib/install-nix.sh
# Users should use install-nix-action if they want to customise how Nix is installed.

set -euo pipefail

emacs_ci_version=$1
[[ -n "$emacs_ci_version" ]]

if ! type -p nix &>/dev/null ; then
    # Configure Nix
    add_config() {
        echo "$1" | tee -a /tmp/nix.conf >/dev/null
    }
    # Set jobs to number of cores
    add_config "max-jobs = auto"
    # Allow binary caches for user
    add_config "trusted-users = root $USER"
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

    if [[ $OSTYPE =~ darwin ]]; then
        # macOS needs certificates hints
        cert_file=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
        echo "NIX_SSL_CERT_FILE=$cert_file" >> "$GITHUB_ENV"
        export NIX_SSL_CERT_FILE=$cert_file
        sudo launchctl setenv NIX_SSL_CERT_FILE "$cert_file"
    fi

    # Set paths
    echo "/nix/var/nix/profiles/per-user/$USER/profile/bin" >> "$GITHUB_PATH"
    echo "/nix/var/nix/profiles/default/bin" >> "$GITHUB_PATH"

    export NIX_PATH=nixpkgs=channel:nixpkgs-unstable
    echo "NIX_PATH=${NIX_PATH}" >> $GITHUB_ENV
fi

PATH="/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/per-user/$USER/profile/bin:$PATH"
nix-env --quiet -j8 -iA cachix -f https://cachix.org/api/v1/install
cachix use emacs-ci

nix-env -iA "$emacs_ci_version" -f "https://github.com/purcell/nix-emacs-ci/archive/master.tar.gz"

emacs -version
