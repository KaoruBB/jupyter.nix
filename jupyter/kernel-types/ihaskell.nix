# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ kernelName, config, jupyterLib, lib, pkgs, ... }:

jupyterLib.kernelspecKernel {

  options = {
    haskellPackageSet = lib.mkOption {
      type = lib.types.functionTo (lib.types.lazyAttrsOf lib.types.anything);
      description = "Selector for the Haskell packages set to use";
      default = pkgs: pkgs.haskellPackages;
      defaultText = lib.literalExpression ''pkgs: pkgs.haskellPackages'';
      example = lib.literalExpression ''pkgs: pkgs.haskell.packages.ghc987'';
    };

    rtsOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "RTS options to pass when running the kernel executable";
      default = [ "-M3g" "-N2" ];
      example = [ "-M128m" ];
    };

    packages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for Haskell packages to include with the kernel";
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
      example = lib.literalExpression ''hp: with hp; [ aeson ihaskell-aeson ]'';
    };
  };

  config =
    let
      haskellPackages = config.haskellPackageSet pkgs;
      kernelEnv = haskellPackages.ghcWithPackages (hp: [
        hp.ihaskell
      ] ++ config.packages hp);

      ghc = haskellPackages.ghc;

      dataDir =
        # The datadir path for packages includes a “unit-id” (`--hash-unit-ids`), which is calculated
        # by GHC and is not really exposed anywhere in Nixpkgs. There is no particularly obvious way
        # to get it, so we just assume there is only a single datadir and therefore grab the first path
        # that matches the glob.
        # FIXME: doing it this way is pretty far from perfect.
        let
          dataDir1 = "${haskellPackages.ihaskell.data}/share/${ghc.targetPrefix}${ghc.haskellCompilerName}";
          files = builtins.readDir dataDir1;
          subdir = lib.head (lib.attrNames files);  # Assume there is exactly one
        in "${dataDir1}/${subdir}/${haskellPackages.ihaskell.name}";

      # Haskell syntax highlighting extension
      jupyterlab-ihaskell = pkgs.runCommandLocal "jupyterlab-ihaskell" { } ''
        extDir="$out/share/jupyter/labextensions"
        mkdir -p -- "$extDir"
        ln -sT -- "${dataDir}/jupyterlab-ihaskell/labextension" "$extDir/jupyterlab-ihaskell"
      '';
    in {
      spec = {
        argv = [
          (lib.getExe' kernelEnv "ihaskell")
          "-l" "${kernelEnv}/lib/${ghc.targetPrefix}${ghc.haskellCompilerName}/lib"
          "kernel"
          "{connection_file}"
          "+RTS"
        ] ++ config.rtsOptions ++ [
          "-RTS"
        ];

        display_name = "IHaskell (${kernelName})";

        language = "haskell";

        logo_svg = "${dataDir}/html/logo-64x64.svg";
      };

      jupyterExtensions = [
        jupyterlab-ihaskell
      ];
    };

}
