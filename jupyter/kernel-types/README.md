<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# How to make a kernel type

## The basics

Start with the following template:

```nix
{ kernelName, name, config, jupyterLib, lib, pkgs, ... }:

jupyterLib.kernelspecKernel {

  options = {
    /* TODO */
  };

  config = {
    spec = {
      /* TODO */
    };
    /* optional */  jupyterEnvPackages = pp: [ /* ...packages... */ ];
    /* optional */  jupyterExtensions = [ /* ...packages... */ ];
  };

}
```

Each kernel module definition will receive the following arguments:

* Standard NixOS module system ones:
  * `config` – current module’s configuration fixpoint;
  * `lib` – Nixpkgs library;
  * `pkgs` – Nixpkgs packages set;
  * `name` – name of the attribute in the attrset the config is in
    (_note:_ this is always the _last_ attribute name, so, in jupyter.nix,
    it is the kernel type, not the kernel name!);
  * ... all other standard arguments.
* Jupyter.nix specific arguments:
  * `kernelName` – actually the name of this kernel in the attrset
    (i.e. the _second-last_ attribute name);
  * `jupyterConfig` – the top-level config of jupyter.nix;
  * `jupyterLib` – the jupyter.nix library.

You can define whatever options make sense for this kernel type.

Your ultimate goal is to produce a Jupyter-JSON-like kernelspec in the `spec` option
(see <https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernel-specs>
for details).

You may also assign to the `jupyterEnvPackages` option – this will cause
the packages you select from the Python packages set (given to your function
as `pp`) to get installed into the Python environment that Jupyter is running from.
`jupyterExtensions` is a list of packages that provide Jupyter extensions that
are required for your kernel and will be installed into the server.

_Note: you do not need to define the `outDir`, `jupyterEnvPackages`, `jupyterExtensions`,
and other options in your module, they will be defined automatically._

## Advanced usage

The `jupyterLib.kernelspecKernel` wrapper is a helper that builds a kernelspec
directory from a JSON-like kernel specification assigned to `spec`.

If you prefer to build the kernelspec directory yourself (or if you already have an
existing directory that you want to use in your kernel), you can skip this function
and instead assign the directory path to the `outDir` option directly.

## Known kernel types

To tell jupyter.nix about your new kernel type, you need to add it to the
`kernelTypes` configuration option:

```nix
jupyter.lib.makeJupyterLab {
  # ...
  kernelTypes = {
    yourNewKernelType = ./path/to/your/kernel/type.nix;
  };
}
```

If you are contributing a new kernel type to jupyter.nix, add it
to the `kernelTypes` attrset in (`lib/default.nix`)[../lib/default.nix].

You can also distribute your kernel type separately, in any manner your like,
and users will be able to activate it by adding it to `kernelTypes` in their own
jupyter.nix configs.
