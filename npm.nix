{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "npm";
  version = "6.11.3";
  nativeBuildInputs = [ pkgs.perl ];
  propagatedBuildInputs = [ pkgs.nodejs ];
  src = builtins.fetchTarball "https://github.com/npm/cli/archive/v${version}.tar.gz";
  configurePhase = "export HOME=$TMP";
}
