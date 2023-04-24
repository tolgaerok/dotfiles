{
  config,
  pkgs,
  user,
  lib,
  inputs,
  ...
}: {
  options.iynaix = {
    zfs = {
      enable = lib.mkEnableOption "Enable zfs" // {default = true;};
      snapshots = lib.mkEnableOption "Enable zfs snapshots" // {default = true;};
    };
  };

  config = lib.mkIf config.iynaix.zfs.enable {
    # booting with zfs
    boot.supportedFilesystems = ["zfs"];
    boot.zfs.devNodes = lib.mkDefault "/dev/disk/by-id";

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    # standard zfs filesystem layout
    fileSystems."/" = {
      device = "zroot/local/root";
      fsType = "zfs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };

    fileSystems."/nix" = {
      device = "zroot/local/nix";
      fsType = "zfs";
    };

    fileSystems."/home" = {
      device = "zroot/safe/home";
      fsType = "zfs";
    };

    fileSystems."/persist" = {
      device = "zroot/safe/persist";
      fsType = "zfs";
    };

    services.sanoid = lib.mkIf config.iynaix.zfs.snapshots {
      enable = true;

      datasets."zroot/safe" = {
        hourly = 50;
        daily = 20;
        weekly = 6;
        monthly = 3;
      };
    };
  };
}
