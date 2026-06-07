<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Add basic support for Jupyter extensions (`jupyterExtensions`
  top-level configuration option and kernel config output option).
* Make the IHaskell kernell install its extension for syntax highlighting.
* Add `extraPath` module for adding directories to the PATH available in the kernel.

### Changed

* For ipykernel, when `enablePlotly = true`, do not install `anywidget` and
  `plotly` Python packages into the Jupyter env, just install the extensions.
* Force read-only extension manager in the webui.
* Add `jupyterLib.kernelspecKernel` helper for defining new kernel types that
  are built from a spec, so there is no need to call `buildKernelSpec` and
  assigning to `outDir` manually.
* Reorganise documentation: the `README.md` is now a concise overview, with
  detailed guides moved into the `doc/` directory (quickstart, examples,
  architecture, kernel authoring). Add a top-level `CONTRIBUTING.md`.

### Fixed

* Account for `targetPrefix` in the IHaskell package datadir path.


## [1.0.0]

First release.


[Unreleased]: https://github.com/kirelagin/jupyter.nix/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/kirelagin/jupyter.nix/releases/tag/v1.0.0
