import * as core from "@actions/core";
import * as exec from "@actions/exec";
import * as io from "@actions/io";
import * as installNix from "./installNix";

async function run() {
  try {
    const version = core.getInput("version");
    const emacsCIVersion = "emacs-" + version.replace(".", "-");

    const nixBuildPath: string = await io.which("nix-build", false);
    if (nixBuildPath === "") {
      core.startGroup("Installing Nix");
      await installNix.run();
      core.endGroup();
    }

    const cachixPath: string = await io.which("cachix", false);
    if (cachixPath === "") {
      core.startGroup("Installing Cachix");
      // TODO: use cachix official installation link
      await exec.exec("nix-env", [
        "-iA",
        "cachix",
        "-f",
        "https://github.com/NixOS/nixpkgs/tarball/ab5863afada3c1b50fc43bf774b75ea71b287cde"
      ]);
      core.endGroup();
    }

    core.startGroup("Enabling cachix for emacs-ci");
    // TODO: use cachix official installation link
    await exec.exec("cachix", ["use", "emacs-ci"]);
    core.endGroup();

    core.startGroup("Installing Emacs");
    // TODO: use cachix official installation link
    await exec.exec("nix-env", [
      "-iA",
      emacsCIVersion,
      "-f",
      "https://github.com/purcell/nix-emacs-ci/archive/master.tar.gz"
    ]);
    core.endGroup();
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
