{
  inputs,
  config,
  ...
}:
{
  flake.aspects.dguibert-git.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-git
  ];

  flake.aspects.dguibert-git.homeManager =
    { pkgs, config, ... }:
    {
      programs.git.enable = true;
      programs.git.package =
        if pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform then pkgs.gitFull else pkgs.gitMinimal;
      programs.git.settings.user.name = "David Guibert";
      programs.git.settings.user.email = "david.guibert@gmail.com";
      programs.git.settings.alias.files =
        "ls-files -v --deleted --modified --others --directory --no-empty-directory --exclude-standard";
      programs.git.settings.alias.wdiff = "diff --word-diff=color --unified=1";
      programs.git.settings.alias.bd =
        "!git for-each-ref --sort='-committerdate:iso8601' --format='%(committerdate:iso8601)%09%(refname)'";
      programs.git.settings.alias.bdr =
        "!git for-each-ref --sort='-committerdate:iso8601' --format='%(committerdate:iso8601)%09%(refname)' refs/remotes/$1";
      programs.git.settings.alias.bs = "branch -v -v";
      programs.git.settings.alias.df = "diff";
      programs.git.settings.alias.dn = "diff --name-only";
      programs.git.settings.alias.dp = "diff --no-ext-diff";
      programs.git.settings.alias.ds = "diff --stat -w";
      programs.git.settings.alias.dt = "difftool";
      #programs.git.ignores
      programs.git.iniContent.clean.requireForce = true;
      programs.git.iniContent.rerere.enabled = true;
      programs.git.iniContent.rerere.autoupdate = true;
      programs.git.iniContent.rebase.autosquash = true;
      programs.git.iniContent.credential.helper = [
        "cache --timeout 86400"
        "store"
        # https://github.com/languitar/pass-git-helper
        # maybe need to define ~/.config/pass-git-helper/git-pass-mapping.ini
        "!type pass-git-helper >/dev/null && pass-git-helper $@"
      ];
      programs.git.iniContent."url \"software.ecmwf.int\"".insteadOf =
        "ssh://git@software.ecmwf.int:7999";
      programs.git.iniContent.color.branch = "auto";
      programs.git.iniContent.color.diff = "auto";
      programs.git.iniContent.color.interactive = "auto";
      programs.git.iniContent.color.status = "auto";
      programs.git.iniContent.color.ui = "auto";
      programs.git.iniContent.diff.tool = "vimdiff";
      programs.git.iniContent.diff.renames = "copies";
      programs.git.iniContent.diff.sopsdiffer.textconv = "sops decrypt";
      programs.git.iniContent.merge.tool = "vimdiff";
      programs.git.iniContent.pull.ff = "only"; # fast-forward only

      programs.git.iniContent.notes.rewrite.amend = true;
      programs.git.iniContent.notes.rewrite.rebase = true;
      programs.git.iniContent.notes.rewriteRefs = "refs/notes/commits";

      home.packages = with pkgs; [
        pass-git-helper
        #  git-remote-gcrypt
        #  (git-crypt.override { git = config.programs.git.package; })
      ];

    };
}
