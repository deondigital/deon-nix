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
    } // {
        npm = import ./npm.nix { inherit pkgs; };
    };

  filters = import ./filters.nix { inherit pkgs; };

  haskell-nix = let
    p = builtins.fromJSON (builtins.readFile pins.haskell-nix);
  in
    import (builtins.fetchGit {
      name = "haskell-nix-lib";
      inherit (p) url rev;
    }) {
      inherit pkgs;
    };

  /*
   * Download/build all NPM dependencies for a Node package ('npm install').
   */
  buildNodeDependencies = { name, srcPath, gitRootDir }: let
    call-node2nix = pkgs.stdenv.mkDerivation {
      name = "${name}-node2nix";
      src = filters.gitTrackedFiles {
        inherit gitRootDir;
        extraFilter = p: t: filters.isFileWithName p t [ "package.json" "package-lock.json" ];
      } srcPath;
      nativeBuildInputs = [ pkgs.nodePackages.node2nix ];
      buildPhase = ''
        node2nix --nodejs-10 --include-peer-dependencies --development -l package-lock.json
      '';
      installPhase = ''
        mkdir $out
        cp node-packages.nix node-env.nix default.nix package.json $out/
      '';
    };
    node-packages = builtins.mapAttrs (name: spec:
      spec.override {
        dontNpmInstall = true;
      }) (pkgs.callPackage call-node2nix { inherit pkgs; });
  in
    pkgs.stdenv.mkDerivation {
      name = "${name}-dependencies";
      unpackPhase = "true";
      dontBuild = true;
      installPhase = ''
        mkdir $out
        ln -s ${node-packages.package}/lib/node_modules/${name}/node_modules $out/node_modules
      '';
    };
}
