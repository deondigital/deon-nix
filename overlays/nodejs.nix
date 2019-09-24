{ pkgs
, ...
}:

let
  npm-version = "6.11.3";
in

self: super: {
  nodejs = super.nodejs.overrideAttrs (oa:
    {
      postInstall = oa.postInstall + ''
        # Upgrade NPM
        npm install npm@${npm-version} -g
      '';
    }
  );
}
