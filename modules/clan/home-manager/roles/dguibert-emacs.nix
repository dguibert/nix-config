{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.clan.home-manager.dguibert;
in
{
  home-manager.users.dguibert = {
    programs.bash.shellAliases.e = "emacsclient -s server -t -a \"\"";
    programs.bash.shellAliases.eg = "emacsclient -s server -n -c -a \"\"";
    home.sessionVariables.ALTERNATE_EDITOR = "";
    home.sessionVariables.EDITOR = "emacsclient -s server -t"; # $EDITOR opens in terminal
    home.sessionVariables.VISUAL = "emacsclient -s server -c -a emacs"; # $VISUAL opens in GUI mode

    programs.emacs.enable = true;
    home.file.".emacs.d/init.el".source = "${inputs.nur_packages}/overlays/emacs.d/init.el";
    home.file.".emacs.d/emacs.org".source = "${inputs.nur_packages}/overlays/emacs.d/emacs.org";
    home.file.".emacs.d/site-lisp".source = "${inputs.nur_packages}/overlays/emacs.d/site-lisp";

    programs.emacs.package = pkgs.my-emacs;
    services.emacs.enable = true;
    services.emacs.socketActivation.enable = true;
    systemd.user.services.emacs.Service.Environment = [
      "COLORTERM=truecolor"
    ];
    home.packages = with pkgs; [
      # my-emacs # 20211026 installed via programs.emacs.package
      my-texlive
    ];
    #home.file.".emacs.d/private.el".source = pkgs.sopsDecrypt_ "${inputs.nur_dguibert}/emacs/private-sec.el" "data";
  };
}
