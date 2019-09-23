{ pkgs
, ...
}:
let
  ## From https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/adoptopenjdk-bin/jdk-darwin-base.nix
  adoptopenjdk-hotspot-bin-8-dd = pkgs.adoptopenjdk-hotspot-bin-8.overrideAttrs (oa:
    if pkgs.stdenv.isDarwin then
    {
      installPhase = ''
        cd ..
        mv $sourceRoot $out
        rm -rf $out/Home/demo
        # Remove some broken manpages.
        rm -rf $out/Home/man/ja*
        # for backward compatibility
        ## This line has been commented out
        # ln -s $out/Contents/Home $out/jre
        ln -s $out/Contents/Home/* $out/
        mkdir -p $out/nix-support
        # Set JAVA_HOME automatically.
        cat <<EOF >> $out/nix-support/setup-hook
        if [ -z "\$JAVA_HOME" ]; then export JAVA_HOME=$out; fi
        EOF
      '';
    } else {}
  );
in

self: super: {
  # Corda require a JDK 1.8.x where x>=171. The default openJDK provides x=121.
  jdk = adoptopenjdk-hotspot-bin-8-dd;
}
