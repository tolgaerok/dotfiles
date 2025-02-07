{user, ...}: {
  config = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users = let
      keyFiles = [
        ../home-manager/id_rsa.pub
        ../home-manager/id_ed25519.pub
      ];
    in {
      root.openssh.authorizedKeys.keyFiles = keyFiles;
      ${user}.openssh.authorizedKeys.keyFiles = keyFiles;
    };

    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # setup autologin
    # NOTE: for autologin, the keyring needs to be setup with a blank password so it can be unlocked on boot
    services.getty.autologinUser = user;
    services.xserver = {
      enable = true;

      displayManager.autoLogin = {
        enable = true;
        inherit user;
      };
    };

    # shut sudo up
    security.sudo.extraConfig = ''
      Defaults passwd_tries=10
      Defaults lecture=never
    '';

    # persist keyring and misc other secrets
    iynaix-nixos.persist.home = {
      directories = [
        ".gnupg"
        ".pki"
        ".ssh"
        ".local/share/keyrings"
      ];
    };
  };
}
