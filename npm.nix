{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "npm";
  version = "6.11.3";
  propagatedBuildInputs = [ pkgs.nodejs ];
  src = builtins.fetchTarball {
    url = "https://github.com/npm/cli/archive/v${version}.tar.gz";
    sha256 = "0hwmwawdcdqx1fs03pd4lzjjr3l626fj6drcf7qg3p3ivqm9i181";
  };
  dontBuild = true;
  # Avoid running ./configure script
  configurePhase = "true";
  installPhase = ''
    mkdir $out
    cp -R bin lib node_modules package.json package-lock.json $out/.
    rm $out/bin/{npm,npx}
    ln -s $out/bin/npm-cli.js $out/bin/npm
    ln -s $out/bin/npx-cli.js $out/bin/npx
  '';
}
