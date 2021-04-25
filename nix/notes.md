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

---

Start with showing a normal Linux package manager package format, how they are built (eg. pacman)
