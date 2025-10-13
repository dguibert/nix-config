{
  description = "A nixpkgs with overlays";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      nixpkgsFor =
        system:
        import (nixpkgs.inputs.nixpkgs or nixpkgs) {
          inherit system;
          overlays = (nixpkgs.legacyPackages.${system}.overlays or [ ]) ++ [
            self.overlays.default
          ];
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
          #config.permittedInsecurePackages = [
          #  "mbedtls-2.28.10" # shadowsocks-libev
          #];
        };
    in
    {
      lib = nixpkgs.lib;

      overlays.default = final: prev: {
        shadowsocks-libev = prev.shadowsocks-libev.overrideAttrs (o: with prev; {
          buildInputs = [
            libsodium
            mbedtls
            libev
            c-ares
            pcre
          ];
          nativeBuildInputs = with prev; [
            cmake
            asciidoc
            xmlto
            docbook_xml_dtd_45
            docbook_xsl
            libxslt
          ];

          patches = (o.patches or []) ++ [
            (prev.fetchpatch {
              url = "https://github.com/shadowsocks/shadowsocks-libev/commit/9afa3cacf947f910be46b69fc5a7a1fdd02fd5e6.patch";
              hash = "sha256-rpWXe8f95UU1DjQpbKMVMwA6r5yGVaDHwH/iWxW7wcw=";
            })
          ];
        });
      };

      legacyPackages.x86_64-linux = nixpkgsFor "x86_64-linux";
      legacyPackages.x86_64-darwin = nixpkgsFor "x86_64-darwin";
      legacyPackages.aarch64-linux = nixpkgsFor "aarch64-linux";
      legacyPackages.aarch64-darwin = nixpkgsFor "aarch64-darwin";
    };
}
