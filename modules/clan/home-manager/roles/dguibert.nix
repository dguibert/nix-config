{ config
, lib
, inputs
, outputs
, pkgsForSystem
, ...
}@args:
with lib;
let
  cfg = config.clan.home-manager.dguibert;
  pkgs = pkgsForSystem config.nixpkgs.system;

  home-secret =
    let
      home_sec = pkgs.sopsDecrypt_ ./dguibert/home-sec.nix "data";
      loaded = home_sec.success or true;
    in
    if loaded
    then (builtins.trace "loaded encrypted ./homes/dguibert/home-sec.nix (${toString loaded})" home_sec)
    else
      (builtins.trace "use dummy        ./homes/dguibert/home-sec.nix (${toString loaded})"
        ({ ... }: { }));

  davmail_ = pkgs.davmail.override {
    jre = pkgs.openjdk.override {
      enableJavaFX = true;
      openjfx17 = pkgs.openjfx17.override { withWebKit = true; };
      openjfx21 = pkgs.openjfx21.override { withWebKit = true; };
      openjfx23 = pkgs.openjfx23.override { withWebKit = true; };
    };
    preferZulu = false;
  };
in
{
  imports = [
    ../common.nix
    ({
      home-manager.extraSpecialArgs = {
        config' = cfg;
      };
      home-manager.users.dguibert = {
        imports = [
          ({ config, pkgs, ... }: {
            home.homeDirectory = "/home/dguibert";
            home.stateVersion = "23.05";
          })
        ];
      };
    })
  ];
  options.clan.home-manager.dguibert = {
    withGui.enable = (mkEnableOption "Host running with X11 or Wayland") // { default = false; };
    withPersistence.enable = mkEnableOption "Use Impermanence";
    centralMailHost.enable = mkEnableOption "Host running liier/mbsync";
    withBash.enable = (lib.mkEnableOption "Enable bash config") // { default = true; };
    withBash.history-merge = (lib.mkEnableOption "Enable bash history merging") // { default = true; };
    withGpg.enable = (lib.mkEnableOption "Enable GPG config") // { default = true; };
    withNix.enable = (lib.mkEnableOption "Enable nix config") // { default = true; };
    withZellij.enable = (lib.mkEnableOption "Enable Zellij config"); # // { default = true; };
    withVSCode.enable = (lib.mkEnableOption "Enable VSCode config"); # // { default = true; };
  };

  config = {
    home-manager.users.dguibert = {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.impermanence.nixosModules.home-manager.impermanence
        {
          withBash.enable = cfg.withBash.enable;
          withBash.history-merge = cfg.withBash.history-merge;
          withGpg.enable = cfg.withGpg.enable;
          withNix.enable = cfg.withNix.enable;
          withZellij.enable = cfg.withZellij.enable;
          withVSCode.enable = cfg.withVSCode.enable;
        }
        ({ config, lib, ... }: {

          config = lib.mkIf cfg.withPersistence.enable
            {
              home.persistence = {
                "/persist/home/${config.home.username}" = {
                  directories = [
                    "archives"
                    "bin"
                    "3D_printing"
                    "code"
                    ".config/Beeper"
                    ".config/calibre"
                    ".config/google-chrome"
                    ".config/kvibes"
                    ".config/OrcaSlicer"
                    ".config/sops"
                    "Documents"
                    ".emacs.private"
                    ".gnupg/private-keys-v1.d"
                    ".local/state/nix"
                    ".mgit"
                    ".mozilla/firefox"
                    ".password-store"
                    ".password-store.git"
                    "Pictures"
                    ".ssh"
                    "templates"
                    ".videos"
                    "Videos"
                    ".vim"
                    "work"
                    #{
                    #  directory = ".local/share/Steam";
                    #  method = "symlink";
                    #}
                  ] ++ optionals cfg.centralMailHost.enable [
                    "Maildir"
                  ];
                  files = [
                    ".bash_history"
                    ".bash_history_backup"
                    ".config/pass-git-helper/git-pass-mapping.ini"
                    ".git-credentials"
                    ".gnupg/pubring.kbx"
                    ".gnupg/trustdb.gpg"
                    ".mrconfig"
                    ".mrtrust"
                    ".signature"
                    ".signature.work"
                    ".vimrc"
                  ] ++ optionals cfg.centralMailHost.enable [
                    ".davmail.properties"
                  ];
                  allowOther = true;
                };
              };
            };
        })
        ({ ... }: {
          sops.age.sshKeyPaths = [ "/home/dguibert/.ssh/id_ed25519" ];
          sops.defaultSopsFile = ./dguibert/secrets.yaml;

          sops.secrets.netrc = { };
          sops.secrets.pass-email1 = { };
          sops.secrets.pass-email2 = { };

          #home.file.".netrc".source = config.sops.secrets.netrc.path;
        })
        inputs.stylix.homeManagerModules.stylix
        # set system's scheme by setting `config.scheme`
        ({ config, ... }: {
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
        })
        ({ config, lib, pkgs, ... }: {
          options.withStylixTheme.enable = mkEnableOption "Stylix Theming" // { default = true; };

          config = lib.mkIf config.withStylixTheme.enable {
            programs.bash.initExtra = ''
              source ${config.lib.stylix.colors { templateRepo=inputs.base16-shell; use-ifd="always"; target = "base16"; }}
            '';
            home.file.".vim/base16.vim".source = config.lib.stylix.colors { templateRepo = inputs.base16-vim; use-ifd = "always"; target = "base16"; };

            xresources.properties = with config.lib.stylix.colors.withHashtag; {
              "*.faceSize" = config.stylix.fonts.sizes.terminal;
            };
          };
        })

        ../report-changes.nix
        ({ ... }: { home.report-changes.enable = true; })

        home-secret

        ({ ... }: { manual.manpages.enable = false; })

        ./dguibert/bash.nix
        ./dguibert/git.nix
        ./dguibert/gpg.nix
        ./dguibert/htop.nix
        ./dguibert/nix.nix
        ./dguibert/ssh.nix
        ./dguibert/zellij.nix
        ./dguibert/vscode.nix
      ]
      ++ lib.optional (cfg.withGui.enable) ./dguibert/with-gui.nix
      ++ lib.optional (cfg.withGui.enable) ./dguibert/module-hyprland.nix
      ++ lib.optional (cfg.withGui.enable) ./dguibert/module-dwl.nix
      ;

      config = {
        programs.home-manager.enable = true;

        nixpkgs.config = {
          # https://nixos.wiki/wiki/Chromium
          chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
        };

        #home.file.".vim/base16.vim".source = ./base16.vim;
        home.file.".editorconfig".source = ./dguibert/editorconfig;

        # http://ubuntuforums.org/showthread.php?t=1150822
        ## Save and reload the history after each command finishes
        home.sessionVariables.SQUEUE_FORMAT = "%.18i %.25P %35j %.8u %.2t %.10M %.6D %.6C %.6z %.15E %20R %W";
        #home.sessionVariables.SINFO_FORMAT="%30N  %.6D %.6c %15F %10t %20f %P"; # with state
        home.sessionVariables.SINFO_FORMAT = "%30N  %.6D %.6c %15F %20f %P";
        # ✗ 1    dguibert@vbox-57nvj72 ~ $ systemctl --user status
        # Failed to read server status: Process org.freedesktop.systemd1 exited with status 1
        # ✗ 130    dguibert@vbox-57nvj72 ~ $ export XDG_RUNTIME_DIR=/run/user/$(id -u)
        home.sessionVariables.XDG_RUNTIME_DIR = "/run/user/$(id -u)";
        home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;

        # Fix stupid java applications like android studio
        home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

        home.packages = with pkgs; [
          (vim_configurable.override {
            guiSupport = "no";
            libX11 = null;
            libXext = null;
            libSM = null;
            libXpm = null;
            libXt = null;
            libXaw = null;
            libXau = null;
            libXmu = null;
            libICE = null;
          })

          rsync

          gnumake
          #nix-repl
          pstree

          screen
          #teamviewer
          lsof
          #haskellPackages.nix-deploy
          htop
          tree

          #wpsoffice
          file
          bc
          unzip

          jq
        ] ++ optionals config.clan.home-manager.dguibert.withGui.enable [
          moreutils
          pandoc

          (pass.withExtensions (extensions: with extensions; [
            # pass-audit #20230419 Error in tests.test_audit.TestPassAudit.test_zxcvbn_strong
            (pass-audit.overrideAttrs (_: {
              doCheck = false;
              doInstallCheck = false;
            }))
            pass-update
            pass-otp
            pass-import
            (pass-checkup.overrideAttrs (_: {
              preBuild = ''
                # unreachable
                sed -i -e 's@RETURNCODE=0@#RETURNCODE=0"@' checkup.bash
                sed -i -e 's@RETURNCODE=2@#RETURNCODE=2"@' checkup.bash
                sed -i -e 's@exit $RETURNCODE@#exit "$RETURNCODE"@' checkup.bash
              '';
            }))
          ]))
          gitAndTools.git-credential-password-store

          gitAndTools.git-remote-gcrypt
          gitAndTools.git-crypt
          tig

          perlPackages.GitAutofixup

          nix-prefetch-scripts
          nix-update

          mr
          mercurial
          #previousPkgs_pu.gitAndTools.git-annex
          yt-dlp
          gitAndTools.git-annex
          gitAndTools.git-annex-remote-rclone
          (pkgs.writeScriptBin "git-annex-diff-wrapper" ''
            #!${pkgs.runtimeShell}
            LANG=C ${pkgs.diffutils}/bin/diff -u "$1" "$2"
            exit 0
          '')
          bup
          par2cmdline
          fpart # ~/Makefile ~/bin/prepare-bd.sh
          rclone
          datalad

          imagemagick
          exiftool
          udftools
          gitAndTools.hub # command-line wrapper for git that makes you better at GitHub

          dwm
          dmenu
          xlockmore
          xautolock
          xorg.xset
          xorg.xinput
          xorg.xsetroot
          xorg.setxkbmap
          xorg.xmodmap
          rxvt-unicode-unwrapped
          st
          dvtm
          abduco
          pamixer
          xsel
          xclip
          #(conky.override { x11Support = false; }) # fails 20230721 conky-1.19.2
          gnuplot
          mkpasswd
          aria2
          qtpass
          qrencode

          go-mtpfs

          wayland
          corkscrew
          autossh

          urlscan

          hledger
          haskellPackages.hledger-interest
          #pythonPackages.ofxparse
          #pkgs-18_09.pythonPackages.weboob
          python3Packages.woob

          mpv
          python3

          baobab
          #bup
          #par2cmdline

          lieer
          muchsync
          notmuch-addrlookup
          #firefox-bin

          terminus_font
          powerline-fonts #corefonts
          fira-code
          fira-code-symbols

          nxsession

          (makeDesktopItem {
            name = "org-protocol";
            exec = "emacsclient %u";
            comment = "Org protocol";
            desktopName = "org-protocol";
            type = "Application";
            mimeTypes = [ "x-scheme-handler/org-protocol" ];
          })
        ] ++ optionals cfg.centralMailHost.enable [
          davmail_
        ];

        # mimeapps.list
        # https://github.com/bobvanderlinden/nix-home/blob/master/home.nix
        home.keyboard.layout = "fr";

        home.file.".conkyrc".text = ''
          conky.config = {
              out_to_console = true,
          };
          conky.text = [[
          ''${loadavg 1} \
          ''${cpu cpu0}% ''${freq_g 0}GHz \
          ''${if_existing /sys/class/power_supply/BAT0/present}Bat ''${battery_percent BAT0}% (''${battery_time BAT0})''${else}\
          ''${if_existing /sys/class/power_supply/BAT1/present}Bat ''${battery_percent BAT1}% (''${battery_time BAT1})''${else}AC''${endif}''${endif} \
          ''${if_up bond0}''${upspeedf bond0}k ''${downspeedf bond0}k ''${endif}\
          ''${if_up enp0s3}''${upspeedf enp0s3}k ''${downspeedf enp0s3}k ''${endif}\
          ''${if_up wlp0s26f7u1}''${upspeedf wlp0s26f7u1}k ''${downspeedf wlp0s26f7u1}k ''${endif}\
          ''${time %H:%M}\
          ]]
        '';
      };

    };
  };
}
