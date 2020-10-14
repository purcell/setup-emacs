import * as core from "@actions/core";
import * as installNix from "./installNix";

async function run() {
  try {
    const version = core.getInput("version");
    const emacsCIVersion = "emacs-" + version.replace(".", "-");
    await installNix.run(emacsCIVersion);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
