# Changelog

## [2.1.0](https://github.com/jmgilman/nixago/compare/v2.0.0...v2.1.0) (2022-06-07)


### Features

* adds plugin for configuring Github ([#15](https://github.com/jmgilman/nixago/issues/15)) ([3506414](https://github.com/jmgilman/nixago/commit/3506414aa958712dadaa4b1f090bbcfd9086e5a6))
* Allows making configurations without a plugin  ([#12](https://github.com/jmgilman/nixago/issues/12)) ([7347fb7](https://github.com/jmgilman/nixago/commit/7347fb7067def9a752ea4c0bd22aaea9c6b54ce5))

## [2.0.0](https://github.com/jmgilman/nixago/compare/v1.0.0...v2.0.0) (2022-06-07)


### ⚠ BREAKING CHANGES

* standardizes the plugin interface (#10)
* adds argument for selecting copy/link mode and output path (#6)
* adds support for passing options to make functions (#4)

### Features

* adds argument for selecting copy/link mode and output path ([#6](https://github.com/jmgilman/nixago/issues/6)) ([59e664c](https://github.com/jmgilman/nixago/commit/59e664ca5de015eb9d232092e90f289b48ceabbc))
* adds support for passing options to make functions ([#4](https://github.com/jmgilman/nixago/issues/4)) ([c459955](https://github.com/jmgilman/nixago/commit/c4599555343c4e2e430ffe7d7bcd06bc7ea4483c))
* standardizes the plugin interface ([#10](https://github.com/jmgilman/nixago/issues/10)) ([2dea0bf](https://github.com/jmgilman/nixago/commit/2dea0bfb843f3a1a3133bbb8854df92d107978c3))

## 1.0.0 (2022-06-01)


### Features

* adds function for building multiple configurations ([298a2a1](https://github.com/jmgilman/nixago/commit/298a2a11078e043131ff38df4247cc2123391ee8))
* adds function for generating lefthook configuration files ([f68e646](https://github.com/jmgilman/nixago/commit/f68e646266df14dc8888c910985641762dbd6ef0))
* adds function for generating prettier ignore files and formats code ([027e0d2](https://github.com/jmgilman/nixago/commit/027e0d2d9083e84e6230e677123c14c6ac1674d8))
* adds generation of Just configuration files ([b603b08](https://github.com/jmgilman/nixago/commit/b603b0847fe9ee9758fca6ca76d9a4dd8c6c2388))
* adds mkShellHook ([b607c95](https://github.com/jmgilman/nixago/commit/b607c9547f2e60f53d9bcc36dc13d8b3e6c0f605))
* adds plugin for conform ([ad34da4](https://github.com/jmgilman/nixago/commit/ad34da40073d67f116d57f119b57f8cbbf3dd8bd))
* adds plugin for Prettier ([db28bf2](https://github.com/jmgilman/nixago/commit/db28bf231e153614bb09a89d34ee0d41f3a1020c))
* adds postBuild argument and formats justfile after generation ([aa68983](https://github.com/jmgilman/nixago/commit/aa68983f8190dcceef34ec574798cccaed847c27))
* adds pre-commit config generation ([c9d7faa](https://github.com/jmgilman/nixago/commit/c9d7faa93dd30a22333c4585da75ebcca54ba24d))
* adds simplified generator for pre-commit configs ([db5403f](https://github.com/jmgilman/nixago/commit/db5403f7f62ce23a8be7da1f3a1bf5f4656dde11))
* adds support for default functions using mkAll ([a4cf4f5](https://github.com/jmgilman/nixago/commit/a4cf4f59195449d7ea51b1510d3bdcca47045f51))


### Bug Fixes

* **conform:** simplifies configuration input ([c981459](https://github.com/jmgilman/nixago/commit/c981459b24552cf7d9a1bcc9a878932d7540587c))
* **just:** fixes improper formatting of tasks ([c64ad25](https://github.com/jmgilman/nixago/commit/c64ad255601b239d4fd05fe90816c25b15361afb))
