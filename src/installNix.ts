// Based on https://github.com/cachix/install-nix-action
import { execFileSync } from 'child_process';

export function run(emacsCIVersion) {
  execFileSync(`${__dirname}/install-nix.sh`, [emacsCIVersion], { stdio: 'inherit' });
}
