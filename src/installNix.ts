// Based on https://github.com/cachix/install-nix-action
import * as core from "@actions/core";
import * as exec from "@actions/exec";
import * as tc from "@actions/tool-cache";
import { homedir, userInfo, type } from "os";
import { existsSync } from "fs";

export async function run() {
  try {
    const home = homedir();
    const { username } = userInfo();
    const PATH = process.env.PATH;
    const CERTS_PATH = home + "/.nix-profile/etc/ssl/certs/ca-bundle.crt";

    // Catalina workaround https://github.com/NixOS/nix/issues/2925
    if (type() == "Darwin") {
      const INSTALL_PATH = "/opt/nix";
      await exec.exec("sudo", [
        "sh",
        "-c",
        `echo \"nix\t${INSTALL_PATH}\"  >> /etc/synthetic.conf`
      ]);
      await exec.exec("sudo", [
        "sh",
        "-c",
        `mkdir -m 0755 ${INSTALL_PATH} && chown runner ${INSTALL_PATH}`
      ]);
      await exec.exec(
        "/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util",
        ["-B"]
      );

      // Needed for sudo to pass NIX_IGNORE_SYMLINK_STORE
      await exec.exec("sudo", [
        "sh",
        "-c",
        "echo 'Defaults env_keep += NIX_IGNORE_SYMLINK_STORE'  >> /etc/sudoers"
      ]);
      core.exportVariable("NIX_IGNORE_SYMLINK_STORE", "1");
    }

    // Workaround a segfault: https://github.com/NixOS/nix/issues/2733
    await exec.exec("sudo", ["mkdir", "-p", "/etc/nix"]);
    await exec.exec("sudo", [
      "sh",
      "-c",
      "echo http2 = false >> /etc/nix/nix.conf"
    ]);

    // Set jobs to number of cores
    await exec.exec("sudo", [
      "sh",
      "-c",
      "echo max-jobs = auto >> /etc/nix/nix.conf"
    ]);

    // TODO: retry due to all the things that go wrong
    const nixInstall = await tc.downloadTool("https://nixos.org/nix/install");
    await exec.exec("sh", [nixInstall]);
    core.exportVariable("PATH", `${PATH}:${home}/.nix-profile/bin`);
    core.exportVariable(
      "NIX_PATH",
      `/nix/var/nix/profiles/per-user/${username}/channels`
    );

    // macOS needs certificates hints
    if (existsSync(CERTS_PATH)) {
      core.exportVariable("NIX_SSL_CERT_FILE", CERTS_PATH);
    }
  } catch (error) {
    core.setFailed(`Action failed with error: ${error}`);
    throw error;
  }
}
