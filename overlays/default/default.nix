final: prev: with final; {
  install-script = drv: with final; writeScript "install-${drv.name}"
    ''#!/usr/bin/env bash
      set -x

      nixos-install --system ${drv} $@

      umount -R /mnt
      zfs set mountpoint=legacy bt580/nixos
      zfs set mountpoint=legacy rt580/tmp
    '';

  conky_nox11 = (conky.override { x11Support = false; });

  python312 = prev.python312.override {
    packageOverrides = python-self: python-super: with python-self; {
      proxy-py = final.lib.upgradeOverride python-super.proxy-py (oldAttrs: rec {
        src = fetchFromGitHub {
          owner = "abhinavsingh";
          repo = "proxy.py";
          rev = "refs/tags/v${oldAttrs.version}";
          hash = "sha256-icFYpuPF76imPxsRcbqvC03pHdGga2GUwvKqbeWg3+E=";
        };
      });
      #boto3 = final.lib.upgradeOverride python-super.boto3 (oldAttrs: rec {
      #  src = fetchFromGitHub {
      #    owner = "boto";
      #    repo = "boto3";
      #    rev = "refs/tags/${oldAttrs.version}";
      #    hash = "sha256-ZipBiB09Bg1D5Ly6R5DkValGe1tDq55b7LnrqU71y/A=";
      #  };

      #});

    };
  };
  nixos-option = prev.nixos-option.override {
    nix = prev.nixStable;
  };
}

