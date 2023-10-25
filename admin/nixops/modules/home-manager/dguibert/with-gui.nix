{ config, lib, pkgs, inputs, outputs, ... }:
{
  config = lib.mkIf config.withGui.enable {
    programs.browserpass.enable = true;

    # https://nixos.wiki/wiki/Firefox
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          ExtensionSettings = { };
        };
      };
    };
    #programs.firefox.extensions =
    #  with pkgs.nur.repos.rycee.firefox-addons; [
    #    browserpass
    #    #switchyomega
    #    ublock-origin
    #];

    programs.google-chrome.enable = true;

    programs.zathura.enable = true;
    programs.zathura.extraConfig = ''
        # zoom and scroll step size
        set zoom-step 20
        set scroll-step 80

      #   # copy selection to system clipboard
      #   set selection-clipboard clipboard

      #   # enable incremental search
      #   set incremental-search true

      #   # zoom
      #   map <C-i> zoom in
      #   map <C-o> zoom out
      #'';

    fonts.fontconfig.enable = lib.mkForce true;

    xresources.properties = with config.scheme.withHashtag; {
      "*visualBell" = false;
      "*urgentOnBell" = true;
      "*font" = "-*-terminus-medium-*-*-*-14-*-*-*-*-*-iso10646-1";
      "*saveLines" = 50000;
      "Rxvt.scrollBar" = false;
      "Rxvt.scrollTtyOutput" = false;
      "Rxvt.scrollTtyKeypress" = true;
      "Rxvt.scrollWithBuffer" = false;
      "Rxvt.jumpScroll" = true;
      "*loginShell" = true;

      "URxvt.searchable-scrollback" = "CM-s";
      "URxvt.utf8" = true;

      "URxvt.transparent" = false;
      "URxvt.depth" = 32;
      "URxvt.intensityStyles" = false;
      "URxvt.termName" = "xterm-256color";
      "st.termname" = "st-256color";
      "st.termName" = "st-256color";
      # Note: colors beyond 15 might not be loaded (e.g., xterm, urxvt),
      # use 'shell' template to set these if necessary
      "*foreground" = base05;
      "*cursorColor" = base05;

      "*color0" = base00;
      "*color1" = base08;
      "*color2" = base0B;
      "*color3" = base0A;
      "*color4" = base0D;
      "*color5" = base0E;
      "*color6" = base0C;
      "*color7" = base05;

      "*color8" = base03;
      "*color9" = base09;
      "*color10" = base01;
      "*color11" = base02;
      "*color12" = base04;
      "*color13" = base06;
      "*color14" = base0F;
      "*color15" = base07;

      "*color16" = base09;
      "*color17" = base0F;
      "*color18" = base01;
      "*color19" = base02;
      "*color20" = base04;
      "*color21" = base06;
    };
    programs.autorandr.enable = true;
    programs.autorandr.profiles.titan-bureau = {
      fingerprint = {
        "HDMI-0" = "00ffffffffffff000469c123010101013419010380331d78eadd45a3554fa027125054afcf80714f8180818fb30081409500a9400101023a801871382d40582c4500fe221100001e000000fd00384b1e530f000a202020202020000000fc0056583233380a20202020202020000000ff0046434c4d52533033333234370a018402031df14a900403011412051f1013230907078301000065030c001000023a801871382d40582c4500fe221100001e011d8018711c1620582c2500fe221100009e011d007251d01e206e285500fe221100001e8c0ad08a20e02d10103e9600fe22110000180000000000000000000000000000000000000000000000000000e6";
        "DVI-D-0" = "00ffffffffffff000469c123010101013419010380331d78eadd45a3554fa027125054afcf80714f8180818fb30081409500a9400101023a801871382d40582c4500fe221100001e000000fd00384b1e530f000a202020202020000000fc0056583233380a20202020202020000000ff0046434c4d52533033333439370a017d02031df14a900403011412051f1013230907078301000065030c001000023a801871382d40582c4500fe221100001e011d8018711c1620582c2500fe221100009e011d007251d01e206e285500fe221100001e8c0ad08a20e02d10103e9600fe22110000180000000000000000000000000000000000000000000000000000e6";
      };
      config = {
        "HDMI-0" = {
          enable = true;
          primary = true;
          position = "1920x0";
          mode = "1920x1080";
        };

        "DVI-D-0" = {
          enable = true;
          position = "0x0";
          mode = "1920x1080";
        };
      };
    };
    programs.autorandr.profiles.t580-thinkvision = {
      fingerprint = {
        #"DVI-I-1-1"="00ffffffffffff0030aeb461010101010c1d0104a53420783e5595a9544c9e240d5054bdcf00d1c0714f818c81008180950f9500b300283c80a070b023403020360006442100001a000000ff0056354747323030350a20202020000000fd00324b1e5311000a202020202020000000fc004c454e20543234642d31300a200121020318f14b010203040514111213901f230907078301000028190050500016300820880006442100001e662156aa51001e30468f330006442100001e483f403062b0324040c0130006442100001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b9";
        "HDMI-2" = "00ffffffffffff0030aeb461010101010c1d0103803420782e5595a9544c9e240d5054bdcf00d1c0714f818c81008180950f9500b300283c80a070b023403020360006442100001a000000ff0056354747323030350a20202020000000fd00324b1e5311000a202020202020000000fc004c454e20543234642d31300a20015702031ef14b010203040514111213901f230907078301000065030c00100028190050500016300820880006442100001e662156aa51001e30468f330006442100001e483f403062b0324040c01300064421000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f";
        "eDP-1" = "00ffffffffffff0030aeba4000000000001c0104a5221378e238d5975e598e271c505400000001010101010101010101010101010101243680a070381f403020350058c210000019502b80a070381f403020350058c2100000190000000f00d10930d10930190a0030e4e705000000fe004c503135365746432d535044420094";
      };
      config = {
        "HDMI-2" = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "1920x1200";
        };

        "eDP-1" = {
          enable = true;
          position = "1920x0";
          mode = "1920x1080";
        };
      };
    };

    programs.autorandr.profiles.t580-thinkvision-on-dock = {
      fingerprint = {
        "DP2-3" = "00ffffffffffff0030aeb461010101010c1d0104a53420783e5595a9544c9e240d5054bdcf00d1c0714f818c81008180950f9500b300283c80a070b023403020360006442100001a000000ff0056354747323030350a20202020000000fd00324b1e5311000a202020202020000000fc004c454e20543234642d31300a200121020318f14b010203040514111213901f230907078301000028190050500016300820880006442100001e662156aa51001e30468f330006442100001e483f403062b0324040c0130006442100001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b9";
        "eDP-1" = "00ffffffffffff0030aeba4000000000001c0104a5221378e238d5975e598e271c505400000001010101010101010101010101010101243680a070381f403020350058c210000019502b80a070381f403020350058c2100000190000000f00d10930d10930190a0030e4e705000000fe004c503135365746432d535044420094";
      };
      config = {
        "DP2-3" = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "1920x1200";
        };

        "eDP-1" = {
          enable = true;
          position = "1920x0";
          mode = "1920x1080";
        };
      };
    };

    #home.file."base16-c_header.h".source =
    #  config.lib.base16.base16template "c_header";


  };
}
