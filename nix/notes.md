Plan a Nix/NixOS monthly meeting talk

• Reproducibility of builds
• Determines output paths before building, allowing binary cache
• NixOS is an extension of Nix that manages the entire operating system declaratively

Extreme example: stateless server or even workstation, "Erase your darlings", https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
You always know the configuration and can reproduce it

Start with neofetch ASCII NixOS logo

Show post flake god complex post

Out of the parts of reproducible builds on https://reproducible-builds.org/, Nix does the second and third things (build environment and way to replicate the steps), it doesn't address eg. Non-reproducibility in compilers

https://tech.channable.com/posts/2021-04-09-nix-is-the-ultimate-devops-toolkit.html
https://nix.dev/

Disadvantages:
• Can't run normal Linux binaries without patching/packaging
• You have to buy in completely to Nix/NixOS to really use it, need to learn an DSL also
• Can't easily upgrade packages piecemeal, everything comes from monolithic nixpkgs
• User experience, documentation is still not the best
• input addressed store means rebuilds happen when any input changes even if the output is ultimately semantically the same, leading to mass rebuilds. See https://www.tweag.io/blog/2020-09-10-nix-cas/. They are working on content addressing but it is slow

---

Cool ideas:
• Make proof of concept embedded deployment, Monash-like
• Build machine automatic deployment, spin up with Nixops
• Build Invetech code with it

# Presentation

## Intro
Nix is a package manager for Linux (and macOS).

Nix is quite different from conventional package managers, and is somewhat complex. As I started planning this presentation I realised that there's way too much to cover in 15 minutes. So this will be a very high-level overview that I threw together, and hopefully it makes sense and maybe gets you interested to know more.

## Conventional package managers

Conventional package managers just put files directly on your root filesystem, and have some metadata (notably dependencies, which other packages should be installed alongside this one).

### Building packages


### Installing packages

There are some problems with this:
- All package installations are modifying a global environment, which leads to:
    - Two packages with the same files can't be installed at the same time, eg. two different versions of a library.
    - If you upgrade a library, the old version is completely replaced, and so you'd better hope all your programs are compatible (ABI changes, etc.)
    - If the package doesn't specify a dependency but it happens to be present on your system, it works anyway.
    - Upgrading packages or sets of packages is not atomic.
    - There's no easy way to roll back package installations.
- Packages are built following a build script, but this is executed in the same global environment, using what is installed.
- Maintainers need a system that rebuilds packages when their dependencies are rebuilt.
- Because a package file is just a collection of files to deploy to the filesystem, it has no direct link to the source code that it was built from.


## The Nix way
So one guy named Eelco Dolstra set out to create a new package management system, and he called it Nix.

- Instead of putting the contents of all packages together in the global filesystem, each one is in a separate unique directory.
    - The name of the directory includes a hash based on the inputs and build specification, so if any input changes, the directory name changes.
- Instead of being built each package is built in an isolated environment with only the dependencies that were specified available.
- Instead of just build scripts for building a package, packages are specified in the Nix language, a lazy, functional language where packages are first-class types.
- Since we know the exact store path name before we even build the package and every store path is unique, we can query a binary cache for the package.


## Practical use
That's all very theoretical. Instead of diving into how Nix works, for today I'll just demonstrate some advantages of the way Nix works.

- Once it is built, the output of any package, or rather derivation (the Nix term for something that can be built) is put into the Nix store at `/nix/store`.
- Each store item is named for its package name and version, but also a hash based on the derivation specification and all the inputs. So rebuilding a deriviation with eg. a different version of a dependency outputs to a different store path.
- Because these are all separate, they can be composed in multiple ways.

- hello is not installed on my system. I can use `nix-shell -p hello` to get a temporary environment with hello in it. It does this by downloading the appropriate prebuilt store paths, then setting the PATH env var to include all the necessary store path bin directories.

- Here I have the definition of the hello package, which I took from nixpkgs. It is defined as a function that takes its dependencies as arguments and returns a derivation.
- I'll build this instead of using the system hello definition with `nix-build hello.nix`.


## NixOS


## Disadvantages
- While the packages themselves are built in a very controlled way, Nix code itself (package definitions) isn't handled as well. Notably, the default at the moment is to have a global system-wide nixpkgs bundle.


## Conclusion
I think the way Nix works is the future - not necessarily Nix itself, but the general philosophy: package isolation, strict dependency management, atomic upgrades, etc.

Nix has promising configuration management, devops stories.

I want to see ideas like this eventually applied at Invetech. One day I want to be able to completely build a complete, ready-to-deploy OS image, including our application, all services configured exactly right, completely reproducibly, with a single command. Whether it be with Nix, or some other tools.

PhD thesis: https://edolstra.github.io/pubs/phd-thesis.pdf
