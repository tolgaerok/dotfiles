{
  lib,
  user,
  ...
}: {
  iynaix-nixos = {
    backlight.enable = true;
    battery.enable = true;
    hyprland.enable = true;
    kanata.enable = true;
    wifi.enable = true;

    # impermanence
    persist.tmpfs = false;
    persist.erase.root = true;
    persist.erase.home = true;
  };

  networking.hostId = "abb4d116"; # required for zfs

  # allow building and pushing of laptop config from desktop
  nix.settings.trusted-users = [user];

  # touchpad support
  services.xserver.libinput.enable = true;

  # do not autologin on laptop!
  services.getty.autologinUser = lib.mkForce null;
  services.xserver.displayManager.autoLogin.enable = lib.mkForce false;
  security.pam.services.gdm.enableGnomeKeyring = true;
}
