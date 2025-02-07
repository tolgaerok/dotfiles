{
  config,
  host,
  lib,
  pkgs,
  ...
}: let
  displays = config.iynaix.displays;
in {
  imports = [
    ./screenshot.nix
    ./startup.nix
    ./lock.nix
    ./swww.nix
    ./waybar
  ];

  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home = {
      sessionVariables = {
        XCURSOR_SIZE = "24";
        HYPR_LOG = "/tmp/hypr/$(command ls -t /tmp/hypr/ | grep -v lock | head -n 1)/hyprland.log";
      };

      packages = with pkgs; [
        # clipboard history
        cliphist
        wl-clipboard
      ];
    };

    wayland.windowManager.hyprland.settings = {
      monitor =
        (lib.forEach displays ({
          name,
          hyprland,
          ...
        }: "${name}, ${hyprland}"))
        ++ [",preferred,auto,auto"];

      input = {
        kb_layout = "us";
        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
          disable_while_typing = true;
        };
      };

      "$mod" =
        if host == "vm"
        then "ALT"
        else "SUPER";

      "$term" = "${config.iynaix.terminal.exec}";

      general = {
        gaps_in = (
          if host == "desktop"
          then 8
          else 4
        );
        gaps_out = (
          if host == "desktop"
          then 8
          else 4
        );
        border_size = 2;
        layout = "master";
      };

      decoration = {
        rounding = 4;
        drop_shadow = host != "vm";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        # dim_inactive = true
        # dim_strength = 0.05

        blur = {
          enabled = host != "vm";
          size = 2;
          passes = 3;
          new_optimizations = true;
        };

        # blurls = rofi
      };

      animations = {
        enabled = host != "vm";
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.05"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];

        animation = [
          "windows, 1, 5, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "windowsMove, 1, 4, smoothIn, slide"
          "border, 1, 5, default"
          "fade, 1, 5, smoothIn"
          "fadeDim, 1, 5, smoothIn"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_is_master = false;
        mfact = "0.5";
        orientation = "left";
        smart_resizing = true;
      };

      binds = {
        workspace_back_and_forth = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        # animate_manual_resizes = true;
        # animate_mouse_windowdragging = true;
        # key_press_enables_dpms = true;
        enable_swallow = false;
        swallow_regex = "^([Kk]itty|[Ww]ezterm)$";
      };

      bind = [
        "$mod, Return, exec, $term"
        "$mod_SHIFT, Return, exec, rofi -show drun"
        "$mod, BackSpace, killactive,"
        "$mod, e, exec, nemo ~/Downloads"
        "$mod_SHIFT, e, exec, $term lf ~/Downloads"
        "$mod, w, exec, brave"
        "$mod_SHIFT, w, exec, brave --incognito"
        "$mod, v, exec, $term nvim"
        "$mod_SHIFT, v, exec, code"
        "$mod, period, exec, code ~/projects/dotfiles"

        # exit hyprland
        "$mod_SHIFT, c, exit,"

        ''CTRL_ALT, Delete, exec, rofi -show power-menu -font "${config.iynaix.fonts.monospace} 14" -modi power-menu:rofi-power-menu''
        "$mod_CTRL, v, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # reset monitors
        "CTRL_SHIFT, Escape, exec, hypr-monitors"

        # bind = $mod, P, pseudo, # dwindle
        # bind = $mod, J, togglesplit, # dwindle

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, j, movefocus, u"
        "$mod, k, movefocus, d"

        "$mod_SHIFT, h, movewindow, l"
        "$mod_SHIFT, l, movewindow, r"
        "$mod_SHIFT, k, movewindow, u"
        "$mod_SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mod_SHIFT, 1, movetoworkspace, 1"
        "$mod_SHIFT, 2, movetoworkspace, 2"
        "$mod_SHIFT, 3, movetoworkspace, 3"
        "$mod_SHIFT, 4, movetoworkspace, 4"
        "$mod_SHIFT, 5, movetoworkspace, 5"
        "$mod_SHIFT, 6, movetoworkspace, 6"
        "$mod_SHIFT, 7, movetoworkspace, 7"
        "$mod_SHIFT, 8, movetoworkspace, 8"
        "$mod_SHIFT, 9, movetoworkspace, 9"
        "$mod_SHIFT, 0, movetoworkspace, 10"

        "$mod, b, layoutmsg, swapwithmaster"

        # focus the previous / next desktop in the current monitor (DE style)
        "CTRL_ALT, Left, workspace, m-1"
        "CTRL_ALT, Right, workspace, m+1"

        # monocle mode
        "$mod, z, fullscreen, 1"

        # fullscreen
        "$mod, f, fullscreen, 0"
        "$mod_SHIFT, f, fakefullscreen"

        # floating
        "$mod, g, togglefloating"

        # sticky
        "$mod, s, pin"

        # focus next / previous monitor
        "$mod, Left, focusmonitor, -1"
        "$mod, Right, focusmonitor, +1"

        # move to next / previous monitor
        "$mod_SHIFT, Left, movewindow, ${
          if builtins.length displays < 3
          then "mon:-1"
          else "mon:l"
        }"
        "$mod_SHIFT, Right, movewindow, ${
          if builtins.length displays < 3
          then "mon:+1"
          else "mon:r"
        }"
        "$mod_SHIFT, Up, movewindow, ${
          if builtins.length displays < 3
          then "mon:-1"
          else "mon:u"
        }"
        "$mod_SHIFT, Down, movewindow, ${
          if builtins.length displays < 3
          then "mon:+1"
          else "mon:d"
        }"

        "ALT, Tab, cyclenext"
        "ALT_SHIFT, Tab, cyclenext, prev"

        # switches to the next / previous window of the same class
        # hardcoded to SUPER so it doesn't clash on VM
        "SUPER, Tab, exec, hypr-same-class next"
        "SUPER_SHIFT, Tab, exec, hypr-same-class prev"

        # picture in picture mode
        "$mod, p, exec, hypr-pip"

        # add / remove master windows
        "$mod, m, layoutmsg, addmaster"
        "$mod_SHIFT, m, layoutmsg, removemaster"

        # rotate via switching master orientation
        "$mod, r, layoutmsg, orientationcycle left top"

        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # turn monitors off
        "$mod_SHIFT_CTRL, l, dpms, off"

        # dunst controls
        "$mod, grave, exec, dunstctl history-pop"

        "$mod, q, exec, wezterm start"

        # switching wallpapers or themes
        "$mod, apostrophe, exec, imv-wallpaper"
        "$mod_SHIFT, apostrophe, exec, rofi-wallust-theme"

        # special keys
        # "XF86AudioPlay, mpvctl playpause"

        # audio
        ",XF86AudioLowerVolume, exec, pamixer -d 5"
        ",XF86AudioRaiseVolume, exec, pamixer -i 5"
        ",XF86AudioMute, exec, pamixer -t"
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # bind workspaces to monitors
      workspace = lib.concatMap ({
        name,
        workspaces,
        ...
      }:
        lib.forEach workspaces (ws: "${toString ws}, monitor:${name}"))
      displays;

      windowrulev2 = [
        # "dimaround,floating:1"
        "bordersize 5,fullscreen:1" # monocle mode
        "float,class:(wlroots)" # hyprland debug session
      ];

      windowrule = [
        # do not idle while watching videos
        "idleinhibit fullscreen,Brave-browser"
        "idleinhibit fullscreen,firefox-aurora"
        "idleinhibit focus,YouTube"
        "idleinhibit focus,mpv"
      ];

      exec-once = [
        # clipboard manager
        "wl-paste --watch cliphist store"
      ];

      # source = "~/.config/hypr/hyprland-test.conf";
    };

    # hyprland crash reports
    iynaix.persist = {
      home.directories = [
        ".hyprland"
      ];
    };
  };
}
