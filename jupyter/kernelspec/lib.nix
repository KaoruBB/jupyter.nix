# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

rec {

  # Helper module that provides common options for spec-based kernel types.
  specKernel = { config, ... }: {
    imports = [
      ./module.nix
    ];

    options = {
      extraPath = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        description = "Extra directories to add to PATH in the kernel";
        default = [ ];
        example = lib.literalExpression ''[ "''${lib.getBin pkgs.hello}/bin" ]'';
      };
    };

    config = {
      spec.env = lib.mkIf (config.extraPath != []) {
        PATH = lib.concatStringsSep ":" (config.extraPath ++ [ "\${PATH}" ]);
      };
    };
  };

  # Utility that evaluates a kernel spec (e.g. for testing).
  evalKernelSpec = pkgs: name: spec:
    lib.evalModules {
      modules = [
        ./module.nix
        {
          options = {
            outDir = lib.mkOption {
              type = lib.types.package;
              internal = true;
              readOnly = true;
            };
          };
          config = {
            _module.args = {
              inherit name pkgs;
            };
            inherit spec;
          };
        }
      ];
    };

  buildKernelSpec = pkgs: name: spec:
    (evalKernelSpec pkgs name spec).config.outDir;
}
