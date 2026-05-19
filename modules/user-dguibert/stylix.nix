{
  lib,
  config,
  inputs,
  ...
}:
{
  flake.aspects.dguibert-stylix.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-stylix
  ];
  flake.aspects.dguibert-stylix.homeManager.imports = [
    inputs.stylix.homeModules.stylix
    # set system's scheme by setting `config.scheme`
    (
      { config, pkgs, ... }:
      {
        stylix.polarity = "dark";
        stylix.image = pkgs.fetchurl {
          url = "https://github.com/hyprwm/Hyprland/raw/main/assets/wall0.png";
          sha256 = "sha256-DF4VzvqWtZONt62BfinrlEfmsO7x79tzYA8vpROQA14=";
        };
        stylix.base16Scheme = "${inputs.tt-schemes}/base16/solarized-dark.yaml";
        stylix.fonts.sizes.applications = 11;
        stylix.fonts.sizes.terminal = 11;

        programs.foot.settings.main.font = "Fira Code:pixelsize=15";

        home.pointerCursor = {
          gtk.enable = true;
          # x11.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 16;
        };

        home.packages = [ pkgs.dconf ];
        gtk = {
          enable = true;

          theme = {
            package = pkgs.flat-remix-gtk;
            name = "Flat-Remix-GTK-Grey-Darkest";
          };

          iconTheme = {
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita";
          };

          font = {
            name = "Sans";
            size = 11;
          };
        };
        stylix.targets.xresources.enable = true;
        stylix.targets.vim.enable = false;
        stylix.targets.emacs.enable = false;
      }
    )
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.withStylixTheme.enable = lib.mkEnableOption "Stylix Theming" // {
          default = true;
        };

        config = lib.mkIf config.withStylixTheme.enable {
          programs.bash.initExtra = ''
            source ${
              config.lib.stylix.colors {
                templateRepo = inputs.base16-shell;
                use-ifd = "always";
                target = "base16";
              }
            }
          '';
          home.file.".vim/base16.vim".source = config.lib.stylix.colors {
            templateRepo = inputs.base16-vim;
            use-ifd = "always";
            target = "tinted-vim";
          };

          xresources.properties = with config.lib.stylix.colors.withHashtag; {
            "*.faceSize" = config.stylix.fonts.sizes.terminal;
          };
        };
      }
    )
  ];
}
