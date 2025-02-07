{
  pkgs,
  user,
  config,
  lib,
  ...
}: let
  cfg = config.iynaix-nixos.virt-manager;
in {
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      virt-manager
      virtiofsd
    ];

    users.users.${user}.extraGroups = ["libvirtd"];

    iynaix-nixos.persist.root.directories = [
      "/var/lib/libvirt"
    ];
  };
}
