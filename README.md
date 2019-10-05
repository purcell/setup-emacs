# A Github Action that installs a specific emacs version

Uses [nix-emacs-ci](https://github.com/purcell/nix-emacs-ci) to provide binaries for a number of different Emacs versions.

Since that project uses Nix, Nix will be installed automatically if
necessary, along with the "cachix" tool which enables downloads of the
cached binaries. If you already have nix and possibly cachix
installed, the existing installations will be used.

See the [actions tab](https://github.com/purcell/setup-emacs) for runs of this action! :rocket:

## Usage:

After testing you can [create a v1 tag](https://github.com/actions/toolkit/blob/master/docs/action-versioning.md) to reference the stable and tested action

```yaml
uses: purcell/setup-emacs@master
with:
  version: 24.5
```

<hr>


[💝 Support this project and my other Open Source work via Patreon](https://www.patreon.com/sanityinc)

[💼 LinkedIn profile](https://uk.linkedin.com/in/stevepurcell)

[✍ sanityinc.com](http://www.sanityinc.com/)

[🐦 @sanityinc](https://twitter.com/sanityinc)
