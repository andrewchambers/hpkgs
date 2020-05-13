# hpkgs

A package repository for [hermes](https://github.com/andrewchambers/hermes).

This repository is self hosting and totally hermetic.

# The Binary Seed

The only input is the seed.hpkg which contains a binary seed, all packages
are derived from this binary seed.

## Regenerating your own seed


### Bootstrapping
To regenerate your own bootstrap binary seed from another linux distro you can use bootstrap.sh.


### Using hermes 

The binary seed can build itself with exact an exact output hash
when hermes is installed in multi user mode.

To do so simply run:

```hermes build -m seed-out.hpkg```

