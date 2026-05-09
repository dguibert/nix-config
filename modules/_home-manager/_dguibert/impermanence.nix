{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.withPersistence;
in
{
  # impermanence HM module uses bindfs, which has absurd performance cost
  # instead, we read these options from nixos impermanence module, and apply
  # them there. this has improved my performance 31 times better
  options = {
    withPersistence.enable = lib.mkEnableOption "Use Impermanence" // {
      default = false;
    };
  };

  # The Home Manager module will be automatically imported by the NixOS module
  #inputs.impermanence.nixosModules.home-manager.impermanence
  config = lib.mkIf cfg.enable {
    home.persistence."/persist".directories = [
      "3D_printing"
      "archives"
      "bin"
      ".cache/aria2"
      "code"
      ".config/Beeper"
      ".config/calibre"
      ".config/FreeCAD"
      ".config/google-chrome"
      ".config/jellyfin-mpv-shim"
      ".config/kvibes"
      ".config/mr"
      ".config/OrcaSlicer"
      ".config/sops"
      "Documents"
      ".emacs.private"
      ".gnupg/private-keys-v1.d"
      ".localhost-nickname"
      ".local/state/nix"
      ".mgit"
      ".mozilla/firefox"
      "Music"
      ".password-store"
      ".password-store.git"
      "Pictures"
      ".ssh"
      "templates"
      ".videos"
      "Videos"
      ".vim"
      "work"
      "ria-store"
      #{
      #  directory = ".local/share/Steam";
      #  method = "symlink";
      #}
    ]
    ++ lib.optionals config.centralMailHost.enable [
      "Maildir"
      "Maildir/.notmuch"
    ];
    home.persistence."/persist".files = [
      #my.persistence.files = [
      ".bash_history"
      ".bash_history_backup"
      ".config/pass-git-helper/git-pass-mapping.ini"
      ".git-credentials"
      ".gnupg/pubring.kbx"
      ".gnupg/trustdb.gpg"
      ".mailcap"
      ".mrconfig"
      ".mrtrust"
      ".signature"
      ".signature.work"
      ".vimrc"
    ]
    ++ lib.optionals config.centralMailHost.enable [
      ".local/state/davmail-tokens"
    ];
  };
}
