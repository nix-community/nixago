{ pkgs, lib, plugins }:
with pkgs.lib;
rec {
  inherit (import ../modules/default.nix { inherit pkgs lib; }) mkRequest;

  eval = import ./eval.nix { inherit pkgs lib plugins; };

  engines = import ./engines { inherit pkgs lib; };

  /* Filters out "empty" values from an attribute set
  */
  filterEmpty = attrs:
    filterAttrs (n: v: v != null && v != "" && v != [ ] && v != { }) attrs;

  generate = import ./generate.nix { inherit pkgs lib plugins; };

  make = import ./make.nix { inherit pkgs lib; };

  /** Recursively makes a list of configurations
  */
  makeAll = import ./make_all.nix { inherit pkgs lib plugins; };

  makeCustom = import ./make_custom.nix { inherit pkgs lib plugins; };

  makeHook = import ./hooks { inherit pkgs lib plugins; };

  /* Updates the the attribute at `path` in `attrs` with `value`.
  */
  updateValue = (attrs: path: value:
    let
      parts = splitString "." path;
    in
    overrideExisting attrs (setAttrByPath parts value)
  );

  /* Takes a set of `overrides` in the format of { "path" = value } and applies
    each override to `attrs`, returning the final result.
  */
  updateAll = (attrs: overrides:
    let
      overrideList = pkgs.lib.mapAttrsToList (name: value: [ "${name}" value ]) overrides;
    in
    builtins.foldl' (x: y: updateValue x (builtins.elemAt y 0) (builtins.elemAt y 1)) attrs overrideList
  );
}
