[![Build Status](https://github.com/purcell/setup-emacs/actions/workflows/test.yml/badge.svg)](https://github.com/purcell/setup-emacs/actions/workflows/test.yml)
<a href="https://www.patreon.com/sanityinc"><img alt="Support me" src="https://img.shields.io/badge/Support%20Me-%F0%9F%92%97-ff69b4.svg"></a>

# A Github Action that installs a specific emacs version

Uses [nix-emacs-ci](https://github.com/purcell/nix-emacs-ci) to provide binaries for a number of different Emacs versions.

Since that project uses Nix, Nix will be installed automatically if
necessary.

Note also that only Linux and MacOS are supported, since Nix is not
available on Windows.

Check out [examples of using this Action in the wild in 1500+ repositories](https://github.com/search?q=purcell%2Fsetup-emacs+++path%3A.github%2Fworkflows%2F*.yml&type=code).

See the [actions tab](https://github.com/purcell/setup-emacs/actions) for runs of this action! :rocket:

## Usage:

```yaml
uses: purcell/setup-emacs@master
with:
  version: 24.5
  ```

The `emacs` executable on the path will then be the requested
version. For a list of available versions, please see the
[nix-emacs-ci](https://github.com/purcell/nix-emacs-ci) project.

For an example of real-life usage, see the [Actions config for `package-lint`](https://github.com/purcell/package-lint/blob/master/.github/workflows/test.yml).

<hr>

#### Note about compiling binary emacs modules

[Here's an example](https://github.com/xuchunyang/strptime.el) of a project which compiles binary modules against an Emacs installed with this method.


[💝 Support this project and my other Open Source work via Patreon](https://www.patreon.com/sanityinc)

[💼 LinkedIn profile](https://uk.linkedin.com/in/stevepurcell)

[✍ sanityinc.com](http://www.sanityinc.com/)

[🐦 @sanityinc](https://twitter.com/sanityinc)
