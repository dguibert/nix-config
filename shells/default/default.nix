{
  config,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    let
      inherit inputs;
      inherit (inputs.sops-nix.packages.${system}) sops-import-keys-hook ssh-to-pgp;
      deploy-rs = pkgs.deploy-rs.deploy-rs;
      pre-commit-check-shellHook = inputs.self.checks.${system}.pre-commit-check.shellHook;

      isNixStore = builtins.storeDir == "/nix/store";
      name =
        if isNixStore then
          "deploy"
        else
          "deploy-${builtins.replaceStrings [ "/" ] [ "-" ] (builtins.dirOf builtins.storeDir)}";
      NIX_CONF_DIR =
        let
          nixConfOrig = builtins.readFile "/etc/nix/nix.conf";
          nixConf = pkgs.writeTextDir "opt/nix.conf" ''
            ${nixConfOrig}
            store = local?store=${builtins.storeDir}&state=${builtins.dirOf builtins.storeDir}/state&log=${builtins.dirOf builtins.storeDir}/log'
            secret-key-files =
          '';
        in
        "${nixConf}/opt";

    in
    {
      devShells.default = pkgs.mkShell rec {
        inherit name;
        ENVRC = name;

        # imports all files ending in .asc/.gpg and sets $SOPS_PGP_FP.
        #sopsPGPKeyDirs = [
        ##  #"./keys/hosts"
        ##  #"./keys/users"
        #];
        # Also single files can be imported.
        sopsPGPKeys = [
          "./keys/users/dguibert.asc"
        ];
        buildInputs =
          with pkgs;
          [
            ssh-to-pgp
            ssh-to-age
            deploy-rs
            #nix-diff # Package ‘nix-diff-1.0.8’ in /nix/store/1bzvzc4q4dr11h1zxrspmkw54s7jpip8-source/pkgs/development/haskell-modules/hackage-packages.nix:174705 is marked as broken, refusing to evaluate.

            jq
            step-ca
            step-cli
            yubikey-manager
            pcsclite
            opensc

            nix
            nix-output-monitor
          ]
          ++ lib.optional isNixStore inputs.clan-core.packages.${system}.clan-cli;
        nativeBuildInputs = [
          sops-import-keys-hook
        ];
        #SOPS_PGP_FP = "";
        sopsCreateGPGHome = "";
        shellHook = ''
          ${pre-commit-check-shellHook}

          unset NIX_INDENT_MAKE
          unset IN_NIX_SHELL NIX_REMOTE
          unset TMP TMPDIR

          unset NIX_STORE NIX_DAEMON
          export PASSWORD_STORE_DIR=$PWD/secrets

          ${
            if !isNixStore then
              ''
                export XDG_CACHE_HOME=$HOME/.cache/${name}
                export NIX_CONF_DIR=${NIX_CONF_DIR}
              ''
            else
              ""
          }
        '';

      };
    };
}
