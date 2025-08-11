{
  _class = "clan.service";
  manifest.name = "adb";

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
        { config, ... }:
        {
          programs.adb.enable = true;
        };
    };
}
