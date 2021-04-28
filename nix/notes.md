# Presentation

## Intro
Nix is a package manager for Linux (and macOS), which can be installed on most distros (including WSL2 which I am using here!).
Its deal is reproducible and declarative system management.

Nix is quite different from conventional package managers, and is somewhat complex. As I started planning this presentation I realised that there's way too much to cover in 15 minutes. So this will be a very high-level overview that I threw together, and hopefully it makes sense and maybe gets you interested to know more.

So why am I talking about a Linux package manager anyway? I think it has cool ideas about reproducibility and configuration management, that I think we need more of here.

## Conventional package managers
Conventional package managers just put files directly on your root filesystem, and have some metadata (notably dependencies, which other packages should be installed alongside this one).

### Building packages
This is an Arch Linux PKGBUILD for Kakoune (the editor I'm using). I'm using Arch as an example here because I'm familiar with it and it's simple, but I think APT/deb and RPM packages work similarly at a high level.

The main things of importance it specifies are the dependencies (ncurses) and how to build the package.

Issues:
- The package is built in the current environment, which is not controlled. Uses whatever is installed (compiler, libraries, etc.). Reproducibility issues.


### Installing packages
The package build system creates a package like this from the PKGBUILD.
It contains the binary files to deploy, and the dependency list is included as metadata.

Issues:
- All package installations are modifying a global environment, which leads to:
    - Two packages with the same files can't be installed at the same time, eg. two different versions of a library.
    - If you upgrade a library, the old version is completely replaced, and so you'd better hope all your programs are compatible (ABI changes, etc.)
    - If the package doesn't specify a dependency but it happens to be present on your system, it works anyway.
    - Upgrading packages or sets of packages is not atomic.
    - There's no easy way to roll back package installations.
- Because a package file is just a collection of files to deploy to the filesystem, it has no direct link to the source code that it was built from.


## The Nix way
So one guy named Eelco Dolstra set out to create a new package management system to solve these problems, and he called it Nix.

- Instead of putting the contents of all packages together in the global filesystem, each one is in a separate unique directory.
    - The name of the directory includes a hash based on the inputs and build specification, so if any input changes, the directory name changes.
- Instead of being built each package is built in an isolated environment with only the dependencies that were specified available. The environment is made as standard as possible. Reproducibility!
- Instead of just build scripts for building a package, packages are specified in the Nix language, a lazy, functional language where packages are first-class types. This is the source of truth for the packages, the binary output is just the result of evaluating the Nix code.


## Practical use
That's all very theoretical. Instead of diving into how Nix works, for today I'll just demonstrate some advantages of the way Nix works.

- Once it is built, the output of any package, or rather derivation (the Nix term for something that can be built) is put into the Nix store at `/nix/store`.
- Each store item is named for its package name and version, but also a hash based on the derivation specification and all the inputs. So rebuilding a deriviation with eg. a different version of a dependency outputs to a different store path.
- Because these are all separate, they can be composed in multiple ways.

### nix-shell
- hello is not installed on my system. I can use `nix-shell -p hello` to get a temporary environment with hello in it. It does this by downloading the appropriate prebuilt store paths, then setting the PATH env var to include all the necessary store path bin directories.
- Here you can see Nix allows you to use packages even if they are not globally "installed". This is how I recommend using Nix most of the time, and not installing packages permanently (which you can do, both per-user and system-wide; it's just symlinking the store paths into an active "profile" directory where you PATH, etc. points).
- You can specify a `shell.nix` to check into your source repo so everyone can have the same environment easily.

### Any changes result in a new store path and a rebuild
- Here I have the definition of the Kakoune package, which I took from nixpkgs. It is defined as a function that takes its dependencies as arguments and returns a derivation.
- I'll build this instead of using the system kakoune definition with `nix-build kakoune.nix`. Since I already have it installed, it just points to the already-existing store path.
- Now if I change anything about this, eg. add a dependency on hello for some reason, then it is rebuilt and gets a new store path.
    - If I change a dependency (it is possible to override attributes of existing packages), then it gets rebuilt, and then this gets rebuilt. This works anywhere in the dependency chain.


## NixOS, Nixops
Using Nix you can have long dependency chains and if anything is updated, all dependents are rebuilt (and can exist alongside the old versions). The final output is completely specified by the Nix code. This makes the Nix code a declarative specification of the output.

What if we could manage not just packages, but the entire operating system configuration this way? That's NixOS.
I don't have time to really go into it today, but let me tell you it is incredible.

Basically, the entire system configuration ends up as a derivation/store path, which depends on literally everything in your system.

I've run NixOS on all my personal machines for a few years. Not on my phone yet, but there's a project to get NixOS running on phones!
Reinstalling gets much easier because I have all my machine configurations in Git and just install the system configuration for that machine to get almost everything back.
A lot of configuration is shared across all machines to give a consistent experience that is easily reproduced.
I literally cannot go back.


## Disadvantages
- Nix is difficult to learn. The documentation is okay, but it isn't the best, and it isn't that good for getting an understanding of how Nix works. The tooling (commands, etc.) is not the most user-friendly either.
- While the packages themselves are built in a very controlled way, Nix code itself (package definitions) isn't handled as well. Notably, the default at the moment is to have a global system-wide nixpkgs bundle (hence the `import <nixpkgs> {}` in the code I've shown).
    - There is an experimental feature called "flakes" which aims to solve this.

• Can't run normal Linux binaries without patching/packaging
• You have to buy in completely to Nix/NixOS to really use it, need to learn an DSL also
• Can't easily upgrade packages piecemeal, everything comes from monolithic nixpkgs
• input addressed store means rebuilds happen when any input changes even if the output is ultimately semantically the same, leading to mass rebuilds. See https://www.tweag.io/blog/2020-09-10-nix-cas/. They are working on content addressing but it is slow
- Out of the parts of reproducible builds on https://reproducible-builds.org/, Nix does the second and third things (build environment and way to replicate the steps), it doesn't address eg. Non-reproducibility in compilers


## Conclusion
I think the way Nix works is the future - not necessarily Nix itself, but the general philosophy: reproducible build environments, package isolation, strict dependency management, atomic upgrades, infrastructure as code, etc.

Nix has promising configuration management, devops stories.

I want to see ideas like this eventually applied at Invetech. One day I want to be able to completely build a complete, ready-to-deploy OS image, including our application, all services configured exactly right, completely reproducibly, with a single command. And I can change one line in a configuration file to change something and it rebuilds exactly how it should with that enabled. Whether it be with Nix, or some other tools.

PhD thesis: https://edolstra.github.io/pubs/phd-thesis.pdf
