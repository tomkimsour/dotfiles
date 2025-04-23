{
  nixGL,
  pkgs,
  ...
}: {
  # https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
  nixGL = {
    packages = nixGL.packages; # you must set this or everything will be a noop
    # For example, the mesa wrapper provides support for running programs on
    # the primary GPU for Intel, AMD and Nouveau drivers, while the mesaPrime
    # wrapper does the same for the secondary GPU.
    defaultWrapper = "mesa";
    offloadWrapper = "nvidiaPrime";
    installScripts = [ "mesa" "nvidiaPrime" ];
    vulkan.enable = false;
  };
}
