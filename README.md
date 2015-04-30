Down for Everyone or Just me
============================

Build Instructions
------------------

Install OCaml 4.02.

Build and install the [OCaml binding of the Firefox Add-on SDK](https://github.com/antoyo/oc-addon-sdk):

1. `ocaml setup.ml -configure --disable-debug`
2. `ocaml setup.ml -build`
3. `ocaml setup.ml -install`

Build the Firefox add-on Down for Everyone or Just me:

1. `ocaml setup.ml -configure --disable-debug`
2. `ocaml setup.ml -build`

The add-on can be used with `cfx run` as usual.
