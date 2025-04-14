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
        deviceUri = "ipp://192.168.1.100/ipp";
        location = "home";
        name = "OKI_MC363_C1E8FC";
        model = "everywhere";
      }
    ];
  };
}
