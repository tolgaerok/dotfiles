{
  user,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.iynaix.wallust;
  random-wallpaper = pkgs.writeShellScriptBin "random-wallpaper" ''
    wallpaper_directory="$HOME/Pictures/Wallpapers/"

    # Find all image files within the wallpaper directory and its subdirectories
    image_files=()
    while IFS= read -r -d "" file; do
        image_files+=("$file")
    done < <(find "$wallpaper_directory" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)

    # Count the number of image files found
    num_files=''${#image_files[@]}

    # Generate a random index within the range of the number of image files
    random_index=''$((RANDOM % num_files))

    # Output the path to the randomly chosen image file
    echo ''${image_files[random_index]}
  '';
in {
  options.iynaix.wallust = with lib.types; {
    enable = lib.mkEnableOption "wallust" // {default = true;};
    threshold = lib.mkOption {
      type = int;
      default = 11;
    };

    entries = lib.mkOption {
      type = attrsOf (submodule {
        options = {
          enable = lib.mkOption {
            type = bool;
            default = false;
            description = "Enable this entry";
          };
          text = lib.mkOption {
            type = str;
            description = "Content of the template file";
          };
          target = lib.mkOption {
            type = str;
            description = "Absolute path to the file to write the template (after templating), e.g. ~/.config/dunst/dunstrc";
          };
        };
      });
      default = [];
      description = ''
        Example entries, which are just a file you wish to apply `wallust` generated colors to.
        template = "dunstrc"
      '';
    };

    # enable wallust for individual programs
    dunst = lib.mkEnableOption "dunst" // {default = cfg.enable;};
    waybar = lib.mkEnableOption "waybar" // {default = cfg.enable;};
    swaylock = lib.mkEnableOption "swaylock" // {default = cfg.enable;};
    rofi = lib.mkEnableOption "rofi" // {default = cfg.enable;};
    zathura = lib.mkEnableOption "zathura" // {default = cfg.enable;};
    wezterm = lib.mkEnableOption "wezterm" // {default = cfg.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = [
        pkgs.wallust
        random-wallpaper
      ];

      # wallust config
      xdg.configFile =
        {
          "wallust/wallust.toml".text =
            ''
              # How the image is parse, in order to get the colors:
              #  * full    - reads the whole image (more precision, slower)
              #  * resized - resizes the image to 1/4th of the original, before parsing it (more color mixing, faster)
              #  * thumb   - fast algo hardcoded to 512x512 (faster than resized)
              #  * wal     - uses image magick `convert` to read the image (less colors)
              backend = "resized"

              # What color space to use to produce and select the most prominent colors:
              #  * lab      - use CIEL*a*b color space
              #  * labmixed - variant of lab that mixes colors, if not enough colors it fallbacks to usual lab,
              # for that reason is not recommended in small images
              color_space = "labmixed"

              # Difference between similar colors, used by the colorspace:
              #  <= 1       Not perceptible by human eyes.
              #  1 - 2      Perceptible through close observation.
              #  2 - 10     Perceptible at a glance.
              #  11 - 49    Colors are more similar than opposite
              #  100        Colors are exact opposite
              threshold = ${toString cfg.threshold}

              # Use the most prominent colors in a way that makes sense, a scheme:
              #  * dark    - 8 dark colors, color0 darkest - color7 lightest, dark background light contrast
              #  * dark16  - same as dark but it displays 16 colors
              #  * light   - 8 light colors, color0 lightest - color7 darkest, light background dark contrast
              #  * light16 - same as light but displays 16 colors
              filter = "dark16"

            ''
            # create entries
            + lib.concatStringsSep "\n" (lib.mapAttrsToList (template: {
              target,
              enable,
              ...
            }:
              if enable
              then ''
                [[entry]]
                template = "${template}"
                target = "${target}"
              ''
              else "")
            cfg.entries);
        }
        // lib.mapAttrs' (
          template: {text, ...}:
            lib.nameValuePair "wallust/${template}" {
              text = text;
            }
        )
        cfg.entries;
    };

    iynaix.persist.home.directories = [
      ".config/wallust"
      ".cache/wallust"
    ];

    iynaix.wallust.entries = {
      "colors.sh" = {
        enable = true;
        text = ''
          wallpaper="{wallpaper}"

          # Special
          background='{background}'
          foreground='{foreground}'
          cursor='{cursor}'

          # Colors
          color0='{color0}'
          color1='{color1}'
          color2='{color2}'
          color3='{color3}'
          color4='{color4}'
          color5='{color5}'
          color6='{color6}'
          color7='{color7}'
          color8='{color8}'
          color9='{color9}'
          color10='{color10}'
          color11='{color11}'
          color12='{color12}'
          color13='{color13}'
          color14='{color14}'
          color15='{color15}'

          # FZF colors
          export FZF_DEFAULT_OPTS="
              $FZF_DEFAULT_OPTS
              --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255
              --color info:7,prompt:2,spinner:1,pointer:232,marker:1
          "

          # Fix LS_COLORS being unreadable.
          export LS_COLORS="''${LS_COLORS}:su=30;41:ow=30;42:st=30;44:"
        '';
        target = "~/.cache/wallust/colors.sh";
      };

      "colors-hexless.sh" = {
        enable = true;
        text = ''
          wallpaper="{wallpaper}"

          # Special
          background='{background.strip}'
          foreground='{foreground.strip}'
          cursor='{cursor.strip}'

          # Colors
          color0='{color0.strip}'
          color1='{color1.strip}'
          color2='{color2.strip}'
          color3='{color3.strip}'
          color4='{color4.strip}'
          color5='{color5.strip}'
          color6='{color6.strip}'
          color7='{color7.strip}'
          color8='{color8.strip}'
          color9='{color9.strip}'
          color10='{color10.strip}'
          color11='{color11.strip}'
          color12='{color12.strip}'
          color13='{color13.strip}'
          color14='{color14.strip}'
          color15='{color15.strip}'

          # FZF colors
          export FZF_DEFAULT_OPTS="
              $FZF_DEFAULT_OPTS
              --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255
              --color info:7,prompt:2,spinner:1,pointer:232,marker:1
          "

          # Fix LS_COLORS being unreadable.
          export LS_COLORS="''${LS_COLORS}:su=30;41:ow=30;42:st=30;44:"
        '';
        target = "~/.cache/wallust/colors-hexless.sh";
      };
    };

    nixpkgs.overlays = [
      (self: super: {
        # creating an overlay for buildRustPackage overlay
        # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
        wallust = super.wallust.overrideAttrs (oldAttrs: rec {
          src = pkgs.fetchgit {
            url = "https://codeberg.org/explosion-mental/wallust.git";
            rev = "f98cc59f7a3584d20a2aae1d8d82cf41f7f2767d";
            sha256 = "sha256-QHCllaS3y/F4aKQYeDEoX9mnGU2LsZphysBizQueWbE=";
          };

          cargoDeps = pkgs.rustPlatform.importCargoLock {
            lockFile = src + "/Cargo.lock";
            allowBuiltinFetchGit = true;
          };
        });
      })
    ];
  };
}
