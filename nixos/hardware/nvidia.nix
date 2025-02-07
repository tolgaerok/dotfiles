{
  config,
  host,
  lib,
  ...
}: let
  cfg = config.iynaix-nixos.nvidia;
in {
  config = lib.mkIf cfg.enable {
    # enable nvidia support
    services.xserver.videoDrivers = ["nvidia"];

    hardware.opengl = {
      enable = true;
      driSupport = true;
    };

    hardware.nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      # prevents crashes with nvidia on resuming, see:
      # https://github.com/hyprwm/Hyprland/issues/804#issuecomment-1369994379
      powerManagement.enable = false;
    };

    hm.wayland.windowManager.hyprland = {
      enableNvidiaPatches = cfg.enable;
      settings.env =
        [
          "NIXOS_OZONE_WL,1"
          "WLR_NO_HARDWARE_CURSORS,1"
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ]
        ++ lib.optionals (host == "vm") [
          "WLR_RENDERER_ALLOW_SOFTWARE,1"
        ];
    };
  };
}
