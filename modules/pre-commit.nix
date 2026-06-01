{
  inputs,
  ...
}:
{
  flake-file.inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      checks = {
        pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
          src = ./..;
          hooks = {
            nixfmt-rfc-style.enable = true;
            nixfmt-rfc-style.excludes = [
              "modules/home-manager/dguibert/home-sec\\.nix"
              "modules/user-dguibert/_home-sec\\.nix"
            ];
            trailing-whitespace = {
              enable = true;
              name = "trim trailing whitespace";
              entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/trailing-whitespace-fixer";
              types = [ "text" ];
              stages = [
                "pre-commit"
                "pre-push"
                "manual"
              ];
            };
            check-merge-conflict = {
              enable = true;
              name = "check for merge conflicts";
              entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/check-merge-conflict";
              types = [ "text" ];
              stages = [
                "pre-commit"
                "pre-push"
              ];
            };
          };
        };
      };
    };
}
