<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Contributing

Thanks for your interest in improving jupyter.nix! Issues and pull requests are
both very welcome.

## Repository layout

```
.
├── flake.nix                Flake outputs: the default package and the checks
├── default.nix              Non-flake compatibility entry point
├── README.md                Project overview and quick start
├── CHANGELOG.md             Keep a Changelog-style history
├── doc/                     Documentation (see below)
└── jupyter/                 The library itself
    ├── lib.nix              Library entry point (exposed as `jupyter.lib`)
    ├── config/module.nix    Top-level configuration module
    ├── kernel/module.nix    The kernel “interface” (output contract)
    ├── kernelspec/          Building a kernel directory from a declarative spec
    └── kernel-types/        Built-in kernel types (ipykernel, ihaskell, …)
```

## Where the documentation lives

User- and developer-facing documentation is in [`doc/`](./doc):

* [`doc/quickstart.md`](./doc/quickstart.md) – getting started and the
  `makeJupyterLab` options.
* [`doc/examples.md`](./doc/examples.md) – example configurations.
* [`doc/architecture.md`](./doc/architecture.md) – how the codebase is
  structured and how it works end to end. **Start here** to understand the code.
* [`doc/kernel-authoring.md`](./doc/kernel-authoring.md) – how to add a new
  kernel type.

A quick map of common tasks:

* **Adding a kernel type** → read [`doc/kernel-authoring.md`](./doc/kernel-authoring.md),
  add an implementation under [`jupyter/kernel-types/`](./jupyter/kernel-types/),
  and register it in [`jupyter/lib.nix`](./jupyter/lib.nix).
* **Changing options shared across all standard kernels** →
  [`jupyter/kernelspec/lib.nix`](./jupyter/kernelspec/lib.nix) (`specKernel`).
* **Changing top-level options or the output derivation** →
  [`jupyter/config/module.nix`](./jupyter/config/module.nix).

## Checks

The flake defines several checks (run `nix flake check`):

* `eval-lib` – the library evaluates.
* `reuse` – REUSE/licensing lint passes.
* `builtin-kernel-types` – every built-in kernel type evaluates.
* `custom-dir-kernel` – a user-defined directory-based kernel type evaluates.

If you add a kernel type, please extend `builtin-kernel-types` accordingly.

## Authorship and licensing (REUSE)

We track authorship for all contributions and follow the [REUSE] practices.
The tl;dr: if your change to a file is *substantial* (you get to judge), add
yourself to that file's SPDX header. New files need an SPDX header too; copy the
style from an existing file of the same type.

[REUSE]: https://reuse.software/

## Changelog

Please reflect notable changes in [`CHANGELOG.md`](./CHANGELOG.md) under the
`Unreleased` section.
