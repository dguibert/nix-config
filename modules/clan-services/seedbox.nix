{
  _class = "clan.service";
  manifest.name = "seedbox";

  roles.default = { };

  perMachine =
    {
      instances,
      settings,
      machine,
      roles,
      ...
    }:
    {
      nixosModule =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          clan.core.vars.generators.aria2 = {
            files.rpc-secret-file.deploy = true;
            runtimeInputs = [
              pkgs.xkcdpass
            ];
            script = ''
              xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > $out/rpc-secret-file
            '';
          };
          # seedbox
          services.aria2 = {
            enable = true;
            openPorts = true;
            serviceUMask = "0002";
            rpcSecretFile = config.clan.core.vars.generators.aria2.files.rpc-secret-file.path;
            settings = {
              #dir = "";
              seed-ratio = "0.0";
              disk-cache = 0;
              file-allocation = "none";
              check-integrity = true;
              always-resume = true;
              #continue=true;
              remote-time = true;

              peer-id-prefix = "-qB0512-";
              peer-agent = "qBittorrent/5.1.2";

            };
          };
        };
    };
}
