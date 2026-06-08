{ lib, config, ... }:
{
  flake.aspects.dguibert-with-3d-tools.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-with-3d-tools
  ];
  flake.aspects.dguibert-with-3d-tools.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        (pkgs.symlinkJoin {
          name = "orca-slicer";
          paths = [ orca-slicer ];
          buildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/orca-slicer \
              --prefix LC_ALL : C \
              --prefix MESA_LOADER_DRIVER_OVERRIDE : zink \
              --prefix WEBKIT_DISABLE_DMABUF_RENDERER : 1 \
              --prefix __EGL_VENDOR_LIBRARY_FILENAMES : ${mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
              --prefix GALLIUM_DRIVER : zink
          '';
        })
        freecad-wayland
      ];
    };
}
