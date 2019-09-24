{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "npm";
  version = "6.11.3";
  propagatedBuildInputs = [ pkgs.nodejs ];
  unpackPhase = "true"; # No sources
  configurePhase = ''
    mkdir -p $out
    export HOME=$TMP
    npm config set prefix $out
  '';
  dontBuild = true;
  installPhase = "npm install npm@${version} -g";
}
