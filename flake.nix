{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      });
    in
    {
      overlays.default = final: prev: {
        format-tables = final.stdenv.mkDerivation rec {
          pname = "format-tables";
          version = "0.1.0";

          src = ./format_tables.sh;

          buildInputs = [ final.vim ];

          phases = [ "installPhase" ];

          installPhase = ''
            install -D $src $out/bin/${pname}
          '';
        };
      };

      packages = forAllSystems (system: rec {
        inherit (nixpkgsFor."${system}")
          format-tables;

        default = format-tables;
      });

      checks = forAllSystems (system: {
        build = self.packages."${system}".default;
      });

      devShells.default = forAllSystems (system: with nixpkgsFor."${system}"; mkShell {
        packages = self.packages."$system";
      });
    };
}
