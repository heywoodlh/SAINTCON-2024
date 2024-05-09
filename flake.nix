{
  description = "SAINTCON 2024 Presentation";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      slides = pkgs.stdenv.mkDerivation rec {
        name = "intro-to-nix";
        src = self;
        buildInputs = with pkgs; [
          coreutils
          marp-cli
        ];
        installPhase = ''
          mkdir $out
          marp --html ${src}/intro-to-nix.md --output $out/intro-to-nix.html
        '';
      };
    in {
      devShell = pkgs.mkShell {
        name = "marp-shell";
        buildInputs = with pkgs; [
          nodejs
          marp-cli
        ];
      };

      packages = rec {
        presentation = slides;
        gen = pkgs.writeShellScriptBin "gen" ''
          cp ${slides}/intro-to-nix.html intro-to-nix.html
          chmod +w intro-to-nix.html
          git add intro-to-nix.html
        '';
        launch = let
          opener = if pkgs.stdenv.isDarwin then "/usr/bin/open" else "${pkgs.xdg-utils}/bin/xdg-open";
        in pkgs.writeShellScriptBin "run" ''
          ${opener} ${slides}/intro-to-nix.html
        '';
        default = launch;
      };

      formatter = pkgs.alejandra;
    });
}
