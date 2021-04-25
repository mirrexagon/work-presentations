let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  name = "rust-shell";

  buildInputs = with pkgs; [
    cargo
    rustc
  ];
}
