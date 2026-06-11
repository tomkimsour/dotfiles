{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Fix for GPU stuff on non-nixos systems
    # ./nixgl.nix
    # ./hyprland.nix
  ];

  # Add packages
  # home.packages = lib.mkMerge [
  #   (with pkgs; [
  #     grim
  #     slurp
  #     swaybg
  #     wdisplays
  #   ])
  # ];
}
