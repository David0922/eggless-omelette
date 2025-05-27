let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in

pkgs.buildEnv {
  name = "chroot";
  paths = with pkgs; [
    pkgs.bash
    pkgs.coreutils
    # pkgs.uutils-coreutils-noprefix
  ];
  pathsToLink = [
    "/bin"
    # "/lib"
    # "/share"
  ];
}
