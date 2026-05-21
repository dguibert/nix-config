{
  inputs,
  config,
  lib,
  ...
}:
let
  home_path = "/home/dguibert";
in
{
  flake.aspects.user-dguibert = {
    nixos =
      { config, ... }:
      {
        users.users.dguibert = {
          isNormalUser = true;
          uid = 1000;
          description = "David Guibert";
          home = home_path;
          group = "dguibert";
          extraGroups = [
            "dguibert"
            "wheel"
            "users"
            "disk"
            "video"
            "audio"
            "adm"
            "systemd-journal"
          ]
          ++ lib.optionals (config.users.groups ? cdrom) [
            "kvm"
          ]
          ++ lib.optionals (config.users.groups ? cdrom) [
            "cdrom"
          ]
          ++ lib.optionals (config.users.groups ? pulse) [
            "pulse"
          ]
          ++ lib.optionals (config.users.groups ? vboxusers) [
            "vboxusers"
          ]
          ++ lib.optionals (config.users.groups ? adbusers) [
            "adbusers"
          ]
          ++ lib.optionals (config.users.groups ? docker) [
            "docker"
          ]
          ++ lib.optionals (config.users.groups ? libvirtd) [
            "libvirtd"
          ]
          ++ lib.optionals (config.users.groups ? disnix) [
            "disnix"
          ]
          ++ lib.optionals (config.users.groups ? seat) [
            "seat"
          ]
          ++ lib.optionals (config.users.groups ? aria2) [
            "aria2"
          ]
          ++ lib.optionals (config.users.groups ? deluge) [
            "deluge"
          ]
          ++ lib.optionals (config.users.groups ? qbittorrent) [
            "qbittorrent"
          ];
          openssh.authorizedKeys.keys = [
            "cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCT6I73vMHeTX7X990bcK+RKC8aqFYOLZz5uZhwy8jtx/xEEbKJFT/hggKADaBDNkJl/5141VUJ+HmMEUMu+OznK2gE8IfTNOP1zLXD6SjOxCa55MvnyIiXVMAr7R0uxZWy28IrmcmSx1LY5Mx8V13mjY3mp3LVemAy9im+vj6FymjQqgPMg6dHq+aQCeHpx22GWHYEq2ghqEsRpmIBBwwaVaEH8YIjcqZwDcp273SzBrgMEW44ndul5bvh85c71vjm7kblU/BxwBeLFMJFnXYTPxF2JjxhCSMlHBH9hqQjQ8vwaQev6XaJ5TpHgiT3nLAxCyBBgvnfwM7oq6bjHjuyToKFzUsFH6YVsK+/NjagZ5YKlV7vK0o2oF12GrQvwWwa6DUM+LdUNmSX4l4Xq8lB5YbJ5NK0pHRRdzCZL5kPuV+CkXRAHoUSj/pLUqkqGRL70NMtLIYmQbj/l7BZ4PQNP9zKLB4f5pk02A25DbPVfoW2DFL0DRfSF1L8ZDsAVhzUaRKSBZZ4wG231gvB6pCMTpeuvC9+Z/OmYkiXEOn34Qdjx8Bfi7XWKm/PnSgP7dM9Tcf3I0hvymvP6eZ8BjeriKHUE7b3s1aMQz9I4ctpbCNT5S16XMQZtdO0HZ+nn4Exhy0FHmdCwPXu/VBEBYcy7UpI4vyb1xiz13KVX/5/oQ== CA key for my accounts at home"
            "cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/ybduCylLGOCgnOdyKZM3rsXr3WnMu9SHSxMV5EY5LkT7Gv1lamNuZbByUY2dPVSgBstYSpbPcmwjYQSqRRuPtgHsRAqvgc2lrGKBKw0tXYgWXFEjXugDMgi9safr86+bbmRhNgU5jzJZ7/BDHDLW5dWMPGK/B6mg9e+E+gZM7Fh99FYn+ys6qB2Ca0tu0jXFLRN5fMe640DI0vjk5lctJikXtfKsyFqiiwjVcqMpVJuCrDpnhp2+uJz/19cjHwjJx8WmLSyYJf0gXlcklgKp781J4D3diLmN9Sz9r22T5WXCiljgsod91eok0rqQxh21DOtGuHXlNkdzjiMHgB/fMAA5NS5ql09cTC4pvL3XQYMbmnGU0gVs25048duwLCs5ISH5kPIsmDUsYU6/O1f7JVboHKNc5EfpGGJnuzUvgLA5ox8tQdHb+DOSp1GSm3JQs6cRzJlW73b/NVPqRqgZVqzC72NkxxdvMrxLE6riajtKW5AU45ZT8hOgNSiQKSxvnc68awni/59aObNEeOJzUo0BqKCB5VLGbK1u6nCrU3l+5U1LXKUDmmokgNOktKRgLkkkXkwfV6o0JKetODZUceN1hfveDpqYZ2Jm43VJrAetUX5AlOqE8z6Ok4RHq79gtBHs5fHEmKW3QeJkau0PDi7BAPSpWy3glZrFTztHgQ== CA key for my accounts at work"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4j+CEKsGc4N/TJ7scLZO6joBjCoEjzalODyoIFvjS6A0bgbvI26KEwt4WCtrMYGn3quni9eQRFn6X/Z9yCxHy8Gugwwj+dHTXEzELABspyyjpgdUphL+2k0eFv7n5/OtWBw3XU/EfXeCAQX7guEdUT4Vavn9fXBIHE46HU+vkgRHib8xrYOwBnQeqEgBkH+qs//0aD1x6X3Wt8W1R+TWM/vjuo/myimYzAxNvdCvlYuWzUNZGMXWmASfnEzTb+W06gtO0ofCaUnlZXmk9Fh9sYSIhEQ4DoyX2Fr3PiaiOE0iQr/kzqrFJ3UrdpHzPp7tehgeaEYOBIXDN6dbAPezJ u0_a81@localhost"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX3tOUaRwa9tVXn7GnU561QtklI6d+VuW/0vwoYiltk a0001 connect bot"
          ];
        };

        users.groups.dguibert.gid = 1000;
      };
  };

  flake.aspects.dguibert.nixos = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager.users.dguibert = {
      imports = [
        config.flake.modules.homeManager.dguibert
        config.flake.modules.homeManager.nixpkgs
      ];
      home.homeDirectory = home_path;
      home.stateVersion = "25.11";

      programs.home-manager.enable = false;
    };
  };

  flake.aspects.dguibert.homeManager =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.report-changes
        config.flake.modules.homeManager.dguibert-home-sec
      ];
      # mimeapps.list
      # https://github.com/bobvanderlinden/nix-home/blob/master/home.nix
      home.keyboard.layout = "fr";

      #home.file.".vim/base16.vim".source = ./base16.vim;
      home.file.".editorconfig".source = ./user-dguibert/_editorconfig;

      # http://ubuntuforums.org/showthread.php?t=1150822
      ## Save and reload the history after each command finishes
      home.sessionVariables.SQUEUE_FORMAT = "%.18i %.25P %35j %.8u %.2t %.10M %.6D %.6C %.6z %.15E %20R %W";
      #home.sessionVariables.SINFO_FORMAT="%30N  %.6D %.6c %15F %10t %20f %P"; # with state
      home.sessionVariables.SINFO_FORMAT = "%30N  %.6D %.6c %15F %20f %P";
      home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;

      # Fix stupid java applications like android studio
      home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

      home.packages = with pkgs; [
        (vim-full.override {
          guiSupport = "no";
          rubySupport = false;
          libsm = false;
          libice = false;
          libx11 = false;
          libxext = false;
          libxpm = false;
          libxt = false;
          libxaw = false;
          libxau = false;
          libxmu = false;
          gtk2-x11 = false;
          gtk3-x11 = false;
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

        st
        dvtm
        abduco
        #(conky.override { x11Support = false; }) # fails 20230721 conky-1.19.2
        gnuplot
        mkpasswd
        aria2
        qtpass
        qrencode

        go-mtpfs

        urlscan

        hledger
        haskellPackages.hledger-interest
        #pythonPackages.ofxparse

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
        powerline-fonts # corefonts
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

      ];

    };
}
