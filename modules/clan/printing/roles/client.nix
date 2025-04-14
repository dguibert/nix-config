{ ... }:
# from https://www.pwg.org/ipp/everywhere.html
{
  # Most printers manufactured after 2013 support the IPP Everywhere protocol
  # https://www.pwg.org/ipp/everywhere.html
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

}
