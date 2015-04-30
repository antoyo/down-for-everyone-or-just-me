Down for Everyone or Just me
============================

Build Instructions
------------------

Install OCaml 4.02.

Build and install the [OCaml binding of the Firefox Add-on SDK](https://github.com/antoyo/oc-addon-sdk).

Build the Firefox add-on Down for Everyone or Just me:

```
ocaml setup.ml -configure --disable-debug
ocaml setup.ml -build
```

The add-on can be used with `cfx run` as usual.
