# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

# This module defines the “interface” of the kernel module, i.e. the options
# that a kernel type’s author is expected to set to “register” their kernel
# with Jupyter.

{ lib, ... }:

{
  options = {
    outDir = lib.mkOption {
      type = lib.types.path;
      description = "Output kernel definition";
      internal = true;
      readOnly = true;
    };

    jupyterEnvPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for extra Python packages to install into the Jupyter python environment";
      internal = true;
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
    };

    jupyterExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Packages containing Jupyter extensions to install. Be careful with package sets to ensure compatibility";
      internal = true;
      default = [ ];
    };
  };
}
