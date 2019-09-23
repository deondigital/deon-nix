{ pkgs
, ...
}:
with pkgs;

rec {
  /*
  * Filter that keeps only those files that are tracked by git.
  * Accepts the argument "extraFilter" and "grepFor".
  *
  * New files do not have to be committed to be
  * included; adding them with `git add` is enough.
  */
  gitTrackedFiles = args: import ./gitSource.nix (
    args // {
      inherit pkgs;
      extraFilter = p: t:
        !isFileWithName p t [ ".gitignore" ] &&
        !isFileWithSuffix p t [ ".nix" ] &&
        (if (builtins.hasAttr "extraFilter" args)
         then args.extraFilter p t
         else true);
    });

  hasName = x: p: t: ns:
    t == x && builtins.any (n: baseNameOf p == n) ns;
  hasSuffix = x: p: t: ss:
    t == x && builtins.any (s: lib.strings.hasSuffix s (baseNameOf p)) ss;
  hasPrefix = x: p: t: ss:
    t == x && builtins.any (s: lib.strings.hasPrefix s (baseNameOf p)) ss;
  isDirWithName = hasName "directory";
  isFileWithName = hasName "regular";
  isFileWithSuffix = hasSuffix "regular";
  isFileWithPrefix = hasPrefix "regular";

  isInSrcDirs = dirs: path:
    builtins.any (i: lib.strings.hasInfix i path) dirs;
}
