# hpkgs

A package repository for [hermes](https://github.com/andrewchambers/hermes).

This repository is self hosting and totally hermetic.

# The Binary Seed

```seed.hpkg``` contains the definitions of the binary seed package,
all other packages are derived from this binary seed.

Hermes uses this binary seed to avoid depending on any system
software installed on your system, creating a self contained and
auditable package set. 

This binary seed contains a statically linked busybox and musl-gcc. 

## Regenerating your own seed

### Bootstrapping
To regenerate your own bootstrap binary seed from another linux distro you can use bootstrap.sh.

### Using hermes 

The binary seed can build itself with exact an exact output hash
when hermes is installed in multi user mode.

To do so simply run:

```hermes build -m seed-out.hpkg```

The hash of this file should match the hash of the input seed, meaning you
have a self hosted software environment with access to all source code.

