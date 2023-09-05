#!/usr/bin/env bash

# This is a cut-down version of https://github.com/cachix/install-nix-action/blob/master/lib/install-nix.sh
# Users should use install-nix-action if they want to customise how Nix is installed.

set -euo pipefail

if ! type -p nix &>/dev/null ; then
    # GitHub command to put the following log messages into a group which is collapsed by default
    echo "::group::Installing Nix"

    # Create a temporary workdir
    workdir=$(mktemp -d)
    trap 'rm -rf "$workdir"' EXIT

    # Configure Nix
    add_config() {
        echo "$1" >> "$workdir/nix.conf"
    }
    add_config "show-trace = true"
    # Set jobs to number of cores
    add_config "max-jobs = auto"
    if [[ $OSTYPE =~ darwin ]]; then
        add_config "ssl-cert-file = /etc/ssl/cert.pem"
    fi
    # Allow binary caches for user
    add_config "trusted-users = root ${USER:-}"
    # Add github access token
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        add_config "access-tokens = github.com=$GITHUB_TOKEN"
    fi

    # Nix installer flags
    installer_options=(
        --no-channel-add
        --darwin-use-unencrypted-nix-store-volume
        --nix-extra-conf-file "$workdir/nix.conf"
    )

    # only use the nix-daemon settings if on darwin (which get ignored) or systemd is supported
    if [[ $OSTYPE =~ darwin || -e /run/systemd/system ]]; then
        installer_options+=(
            --daemon
            --daemon-user-count "$(python3 -c 'import multiprocessing as mp; print(mp.cpu_count() * 2)')"
        )
    else
        # "fix" the following error when running nix*
        # error: the group 'nixbld' specified in 'build-users-group' does not exist
        add_config "build-users-group ="
        sudo mkdir -p /etc/nix
        sudo chmod 0755 /etc/nix
        sudo cp "$workdir/nix.conf" /etc/nix/nix.conf
    fi

    # There is --retry-on-errors, but only newer curl versions support that
    curl_retries=5
    while ! curl -sS -o "$workdir/install" -v --fail -L "https://releases.nixos.org/nix/nix-2.17.0/install"
    do
        sleep 1
        ((curl_retries--))
        if [[ $curl_retries -le 0 ]]; then
            echo "curl retries failed" >&2
            exit 1
        fi
    done

    sh "$workdir/install" "${installer_options[@]}"

    # Set paths
    echo "/nix/var/nix/profiles/default/bin" >> "$GITHUB_PATH"
    # new path for nix 2.14
    echo "$HOME/.nix-profile/bin" >> "$GITHUB_PATH"

    # Unlike upstream install-nix-action, we enable a default channel
    export NIX_PATH=nixpkgs=channel:nixpkgs-unstable
    echo "NIX_PATH=${NIX_PATH}" >> "$GITHUB_ENV"

    # Close the log message group which was opened above
    echo "::endgroup::"

    # Apply the changes immediately for the subsequent commands
    while IFS= read -r line; do
        PATH="$PATH:$line"
    done < "$GITHUB_PATH"
    source "$GITHUB_ENV"
fi

echo "::group::Installing Emacs into active nix profile"
mkdir -p "$HOME/.config/nix"
echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
nix profile install --accept-flake-config "github:purcell/nix-emacs-ci#emacs-${INPUT_VERSION/./-}"
echo "::endgroup::"
