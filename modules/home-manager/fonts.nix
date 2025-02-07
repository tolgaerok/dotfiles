{
  lib,
  pkgs,
  ...
}: {
  options.iynaix = {
    fonts = {
      regular = lib.mkOption {
        type = lib.types.str;
        default = "Inter";
        description = "The font to use for regular text";
      };
      monospace = lib.mkOption {
        type = lib.types.str;
        default = "JetBrainsMono Nerd Font";
        description = "The font to use for monospace text";
      };
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          font-awesome
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Ubuntu"];})
        ];
        description = "The packages to install for the fonts";
      };
    };
  };
}
