{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "npm";
  version = "6.11.3";
  nativeBuildInputs = [ pkgs.perl ];
  propagatedBuildInputs = [ pkgs.nodejs ];
  src = builtins.fetchTarball "https://github.com/npm/cli/archive/v${version}.tar.gz";
  configurePhase = ''
    mkdir -p $out
    export HOME=$TMP
    cat << EOF > $HOME/.npmrc
    prefix = $out/.npm-packages
    EOF
  '';
  postInstall = ''
    mkdir $out/bin
    ln -s .npm-packages/bin/npm $out/bin/npm
    ln -s .npm-packages/bin/npx $out/bin/npx
  '';
}
