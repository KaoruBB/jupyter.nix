# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ config, lib, ... }:

{
  options.collaboration = {
    enable = lib.options.mkEnableOption "jupyter-collaboration";
  };

  config = lib.mkIf config.collaboration.enable {
    jupyterEnvPackages = pp: [ pp.jupyter-server-ydoc ];

    labExtensions = with (config.pythonInterpreter config.pkgs).pkgs; [
      jupyter-collaboration-ui
      jupyter-docprovider
    ];
  };
}
