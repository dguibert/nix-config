{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.clan.home-manager.dguibert;
in
{
  home-manager.users.dguibert = {
    imports = [
      ../../../../modules/home-manager/dguibert/emacs.nix
      {
        withEmacs.enable = true;
      }
    ];
    #home.file.".emacs.d/private.el".source = pkgs.sopsDecrypt_ "${inputs.nur_dguibert}/emacs/private-sec.el" "data";
  };
}
