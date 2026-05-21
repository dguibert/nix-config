{
  flake.aspects.report-changes = {
    nixos =
      { config, ... }:
      {
        system.activationScripts.nvd = ''
          echo "Diffing: $(readlink /run/current-system) $systemConfig"
          ${config.nix.package}/bin/nix store diff-closures /run/current-system $systemConfig || true
        '';
      };

    homeManager =
      { activationPkgs, config, ... }:
      {
        home.activation.report-changes = config.lib.dag.entryAnywhere ''
          if [[ -v oldGenPath ]]; then
              echo "Diffing: $oldGenPath $newGenPath"
              run ${activationPkgs.nix}/bin/nix store diff-closures $oldGenPath $newGenPath || true
          fi
        '';
      };
  };
}
