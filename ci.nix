# Used by Hercules CI
{
  system ? builtins.currentSystem,
}:
let
  flake = builtins.getFlake (toString ./.);
  hosts = builtins.getAttrs flake.nixosConfigurations;
in
flake.checks
// builtins.mapAttrs (n: v: v.config.system.build.toplevel) flake.nixosConfigurations
// {

}
