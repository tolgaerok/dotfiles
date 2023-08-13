{
  lib,
  isNixOS,
  ...
}: {
  options.iynaix = {
    helix.enable = lib.mkEnableOption "helix";
    kitty.enable = lib.mkEnableOption "kitty" // {default = isNixOS;};
    pathofbuilding.enable = lib.mkEnableOption "pathofbuilding" // {default = isNixOS;};
    trimage.enable = lib.mkEnableOption "trimage";
    vlc.enable = lib.mkEnableOption "vlc";
    wezterm.enable = lib.mkEnableOption "wezterm" // {default = isNixOS;};
  };
}
