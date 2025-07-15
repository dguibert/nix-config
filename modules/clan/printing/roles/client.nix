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

  services.printing.enable = true;
  hardware.printers = {
    ensureDefaultPrinter = "OKI_MC363_C1E8FC";
    ensurePrinters = [
      {
        deviceUri = "ipp://oki-mc363-c1e8fc.local:631/ipp/print";
        location = "home";
        name = "OKI_MC363_C1E8FC";
        model = "everywhere";
      }
    ];
  };
}
