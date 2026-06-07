# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

let
  kernelspecLib = import ./kernelspec/lib.nix { inherit lib; };

  # A helper for defining spec-based kernels.
  # Normally, kernels are expected to produce `outDir` with a Jupyter
  # kernelspec (see `./kernel/module.nix`), however wrapping the module
  # by calling this function makes it so you need to populate the
  # `spec` option (`./kernelspec/module.nix`) instead and `outDir` will
  # be built automatically.
  kernelspecKernel = module: {
    imports = [
      module
      kernelspecLib.specKernel
    ];
  };

  # Built-in kernel types.
  kernelTypes = import ./kernel-types.nix { inherit kernelspecKernel; };

  jupyterLib = rec {
    evalJupyterConfig = config:
      lib.evalModules {
        modules = [
          ./config/module.nix
          {
            config = { inherit kernelTypes; };
          }
          { inherit config; }
        ];
        specialArgs = {
          inherit jupyterLib;
        };
      };

    makeJupyterLab = config:
      (evalJupyterConfig config).config.outDrv;

    inherit kernelspecKernel;

    inherit (kernelspecLib) buildKernelSpec;
  };

in jupyterLib
