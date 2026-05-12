{
  config,
  lib,
  pkgs,
  ...
}:

{
  flake.aspects.user-root.nixos = {
    # https://www.sweharris.org/post/2016-10-30-ssh-certs/
    # http://www.lorier.net/docs/ssh-ca
    # https://linux-audit.com/granting-temporary-access-to-servers-using-signed-ssh-keys/
    users.users.root.openssh.authorizedKeys.keys = [
      "cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCT6I73vMHeTX7X990bcK+RKC8aqFYOLZz5uZhwy8jtx/xEEbKJFT/hggKADaBDNkJl/5141VUJ+HmMEUMu+OznK2gE8IfTNOP1zLXD6SjOxCa55MvnyIiXVMAr7R0uxZWy28IrmcmSx1LY5Mx8V13mjY3mp3LVemAy9im+vj6FymjQqgPMg6dHq+aQCeHpx22GWHYEq2ghqEsRpmIBBwwaVaEH8YIjcqZwDcp273SzBrgMEW44ndul5bvh85c71vjm7kblU/BxwBeLFMJFnXYTPxF2JjxhCSMlHBH9hqQjQ8vwaQev6XaJ5TpHgiT3nLAxCyBBgvnfwM7oq6bjHjuyToKFzUsFH6YVsK+/NjagZ5YKlV7vK0o2oF12GrQvwWwa6DUM+LdUNmSX4l4Xq8lB5YbJ5NK0pHRRdzCZL5kPuV+CkXRAHoUSj/pLUqkqGRL70NMtLIYmQbj/l7BZ4PQNP9zKLB4f5pk02A25DbPVfoW2DFL0DRfSF1L8ZDsAVhzUaRKSBZZ4wG231gvB6pCMTpeuvC9+Z/OmYkiXEOn34Qdjx8Bfi7XWKm/PnSgP7dM9Tcf3I0hvymvP6eZ8BjeriKHUE7b3s1aMQz9I4ctpbCNT5S16XMQZtdO0HZ+nn4Exhy0FHmdCwPXu/VBEBYcy7UpI4vyb1xiz13KVX/5/oQ== CA key for my accounts at home"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX3tOUaRwa9tVXn7GnU561QtklI6d+VuW/0vwoYiltk a0001 connect bot"
    ];
  };

  configurations.home."root@x86_64".system = "x86_64-linux";
  configurations.home."root@x86_64".module = config.flake.modules.homeManager.root;

  configurations.home."root@aarch64".system = "aarch64-linux";
  configurations.home."root@aarch64".module = config.flake.modules.homeManager.root;

  flake.aspects.root.homeManager =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.report-changes
      ];
      manual.manpages.enable = false;
      home.username = "root";
      home.homeDirectory = "/root";

      programs.bash.shellAliases.ls = "ls --color";

      programs.bash.initExtra = ''
        # Provide a nice prompt.
        PS1=""
        PS1+='\[\033[01;37m\]$(exit=$?; if [[ $exit == 0 ]]; then echo "\[\033[01;32m\]✓"; else echo "\[\033[01;31m\]✗ $exit"; fi)'
        PS1+='$(ip netns identify 2>/dev/null)' # sudo setfacl -m u:$USER:rx /var/run/netns
        PS1+=' ''${GIT_DIR:+ \[\033[00;32m\][$(basename $GIT_DIR)]}'
        PS1+=' ''${ENVRC:+ \[\033[00;33m\]env:$ENVRC}'
        PS1+=' ''${SLURM_NODELIST:+ \[\033[01;34m\][$SLURM_NODELIST]\[\033[00m\]}'
        PS1+=' \[\033[00;31m\]\u@\h\[\033[01;34m\] \W '
        if ! command -v __git_ps1 >/dev/null; then
          if [ -e $HOME/code/git-prompt.sh ]; then
            source $HOME/code/git-prompt.sh
          fi
        fi
        if command -v __git_ps1 >/dev/null; then
          PS1+='$(__git_ps1 "|%s|")'
        fi
        PS1+='$\[\033[00m\] '

        export PS1
        case $TERM in
          dvtm*|st*|rxvt|*term)
            trap 'echo -ne "\e]0;$BASH_COMMAND\007"' DEBUG
          ;;
        esac

        eval "$(${pkgs.coreutils}/bin/dircolors)"
      '';

      programs.direnv.enable = true;

      programs.bash.enable = true;
      programs.bash.historySize = 50000;
      programs.bash.historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      programs.bash.historyIgnore = [
        "ls"
        "cd"
        "clear"
        "[bf]g"
      ];

      home.sessionVariables.PROMPT_COMMAND = "history -a; history -c; history -r";
      home.sessionVariables.EDITOR = "vim";
      home.sessionVariables.GIT_PS1_SHOWDIRTYSTATE = 1;

      home.packages = with pkgs; [
        (vim-full.override {
          guiSupport = "no";
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
        editorconfig-core-c
      ];
      home.file.".inputrc".text = ''
        set show-all-if-ambiguous on
        set visible-stats on
        set page-completions off
        # http://www.caliban.org/bash/
        #set editing-mode vi
        #set keymap vi
        set show-all-if-ambiguous on
        #Control-o: ">&sortie"
        "\e[A": history-search-backward
        "\e[B": history-search-forward

        "\e[1~": beginning-of-line
        "\e[4~": end-of-line
        "\e[7~": beginning-of-line
        "\e[8~": end-of-line
        "\eOH": beginning-of-line
        "\eOF": end-of-line
        "\e[H": beginning-of-line
        "\e[F": end-of-line
      '';

      # mimeapps.list
      # https://github.com/bobvanderlinden/nix-home/blob/master/home.nix
      home.keyboard.layout = "fr";

      home.stateVersion = "20.09";
    };
}
