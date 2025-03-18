{ config, lib, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    #acceleration = "cuda";
  };
  #ollama run codellama:13b-instruct "Write an extended Python program with a typical structure. It should print the numbers 1 to 10 to standard output."

  services.open-webui.enable = true;
}
