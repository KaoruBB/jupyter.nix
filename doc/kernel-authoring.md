<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Authoring a kernel type

A *kernel type* is a reusable implementation of a kind of Jupyter kernel (for
example, `ipykernel` for Python or `ihaskell` for Haskell). Users instantiate
a kernel type by writing `kernels.<name>.<type> = { … }` in their configuration.

This guide explains how to write your own kernel type. For the bigger picture of
how the pieces fit together, see [`architecture.md`](./architecture.md).

## The basics

Start from this template:

```nix
{ kernelName, name, config, jupyterConfig, jupyterLib, lib, pkgs, ... }:

jupyterLib.kernelspecKernel {

  options = {
    /* TODO: options specific to your kernel type */
  };

  config = {
    spec = {
      /* TODO: fill in the Jupyter kernel spec */
    };
    /* optional */ jupyterEnvPackages = pp: [ /* ...packages... */ ];
    /* optional */ jupyterExtensions = [ /* ...packages... */ ];
  };

}
```

A kernel type is just a NixOS module. `jupyterLib.kernelspecKernel` wraps your
module so that you only need to fill in a declarative `spec` and the kernel
directory (`outDir`) is built for you.

## Module arguments

Your module receives the standard NixOS module-system arguments plus a few
jupyter.nix-specific ones.

Standard arguments:

* `config` – this module's configuration fixpoint;
* `lib` – the Nixpkgs library;
* `pkgs` – the Nixpkgs package set (the user's `pkgs`);
* `name` – the *last* attribute name, which in jupyter.nix is the **kernel
  type**, not the kernel name (this is a quirk of how the option type is built;
  see [`architecture.md`](./architecture.md));
* … all other standard module arguments.

jupyter.nix-specific arguments:

* `kernelName` – the name the user gave this kernel (the second-to-last
  attribute name, i.e. the `<name>` in `kernels.<name>.<type>`); use this for
  `display_name`, for instance;
* `jupyterConfig` – the top-level jupyter.nix configuration. Useful fields
  include `jupyterConfig.pkgs` and `jupyterConfig.pythonInterpreter` (so your
  kernel can match the Python interpreter Jupyter itself uses);
* `jupyterLib` – the jupyter.nix library, which provides `kernelspecKernel` and
  `buildKernelSpec`.

## Producing the kernel spec

Your goal is to populate the `spec` option, which mirrors a
[Jupyter kernel spec][jupyter:kernelspec]. The required fields are `argv`,
`display_name`, and `language`; logos and a few other fields are optional. See
[`jupyter/kernelspec/module.nix`](../jupyter/kernelspec/module.nix) for the full
list of available options.

[jupyter:kernelspec]: https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernel-specs

## Adding packages and extensions to the server

Besides the kernel itself, you can influence the Jupyter *server* environment:

* `jupyterEnvPackages` – a selector (`pp: [ … ]`) for Python packages that must
  be installed into the environment Jupyter runs from. Use this for packages
  that need to live in *both* the kernel and the server (for example,
  Matplotlib's `ipympl`).
* `jupyterExtensions` – a list of packages providing Jupyter Lab extensions
  required by your kernel. Be careful to keep extension package sets compatible
  with the Jupyter Lab version in use.

You do **not** need to declare `outDir`, `jupyterEnvPackages`, or
`jupyterExtensions` as options yourself — they come from the common kernel
interface ([`jupyter/kernel/module.nix`](../jupyter/kernel/module.nix)).

## Extra conveniences from `specKernel`

`kernelspecKernel` mixes in the `specKernel` helper
([`jupyter/kernelspec/lib.nix`](../jupyter/kernelspec/lib.nix)), which adds:

* `extraPath` – a list of directories to prepend to the kernel's `PATH` at
  runtime. This is handy when your kernel needs extra executables available:

  ```nix
  config.extraPath = [ "${lib.getBin pkgs.hello}/bin" ];
  ```

## Advanced: building `outDir` yourself

`kernelspecKernel` is only a convenience. If you already have a kernelspec
directory, or want to build it yourself, skip `kernelspecKernel` and assign the
directory path to `outDir` directly:

```nix
{ ... }:
{
  imports = [ /* the kernel interface is added for you by jupyter.nix */ ];
  config.outDir = /* a path to a directory with kernel.json, logos, … */;
}
```

See the `custom-dir-kernel` example in [`examples.md`](./examples.md).

## Registering a kernel type

To make a kernel type usable, it must be in the `kernelTypes` registry.

Users can register a kernel type without modifying jupyter.nix:

```nix
jupyter.lib.makeJupyterLab {
  # ...
  kernelTypes = {
    yourNewKernelType = ./path/to/your/kernel-type.nix;
  };
  kernels = {
    "my-kernel".yourNewKernelType = { /* ... */ };
  };
}
```

If you are contributing a kernel type *to* jupyter.nix,
drop the implementation file in [`jupyter/kernel-types/`](../jupyter/kernel-types/)
and add it to [`jupyter/kernel-types.nix`](../jupyter/kernel-types.nix).

You can also distribute a kernel type independently; users activate it via
`kernelTypes` as shown above.
