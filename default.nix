# Deon Digital common Nix configuration
rec {
  pins = {
    nixpkgs = pins/nixpkgs-src.json;
    haskell-nix = pins/haskell-nix-src.json;
  };

  pkgs = let
    p = builtins.fromJSON (builtins.readFile pins.nixpkgs);
  in
    import (builtins.fetchGit {
      name = "nixos-unstable-2019-09-11";
      inherit (p) url rev;
    }) {
      overlays = [
        (import overlays/jdk.nix { inherit pkgs; })
      ];
    };

  filters = import ./filters.nix { inherit pkgs; };

  /*
   * Download/build all NPM dependencies for a Node package ('npm install').
   */
  buildNodeDependencies = name: srcPath: pkgs.stdenv.mkDerivation {
    name = "${name}-dependencies";
    nativeBuildInputs = [ pkgs.nodejs ];
    src = filters.gitTrackedFiles {
      extraFilter = p: t: filters.isFileWithName p t ["package.json" "package-lock.json"];
    } srcPath;
    buildPhase = ''
      export HOME=$TMP
      npm install
    '';
    installPhase = ''
      mkdir $out
      cp -r node_modules $out/
      cp package.json $out/
      cp package-lock.json $out/
    '';
  };
}
