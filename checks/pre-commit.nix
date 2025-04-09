{ config, withSystem, inputs, ... }:
{
  perSystem = { config, self', inputs', pkgs, system, ... }: {
    checks = {
      pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
        src = ./..;
        hooks = {
          nixfmt-rfc-style.enable = true;
          prettier.enable = true;
          prettier.stages = [ "pre-commit" ];
          trailing-whitespace = {
            enable = true;
            name = "trim trailing whitespace";
            entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/trailing-whitespace-fixer";
            types = [ "text" ];
            stages = [ "pre-commit" "pre-push" "manual" ];
          };
          check-merge-conflict = {
            enable = true;
            name = "check for merge conflicts";
            entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/check-merge-conflict";
            types = [ "text" ];
            stages = [ "pre-commit" "pre-push" ];
          };
        };
      };
    };
  };
}
