# Tips and tricks

Building packages from source can be quite tricky, and here are some tips and
tricks you can use when writing `hpkg`s.

### Build it manually first

It can be tempting to jump right in, but if you don't spend up front time learning how to
build the software manually, you might have some pain.

For difficult packages, consider investing in a 'shell' package,
which just contains a way to run commands with env vars set for you to test with.
This should help you manually test things with a fast iteration time.

In the future hpkgs may come with helper functions or a repl for helping you do this.

### Determine what the package's build system(s) is/are

* It might contain configurations for script-generating systems, for example,
  GNU Autotools (autoconf/configure).
* Some sources include a simple Makefile with a custom build process.
* Other sources contain configurations for use with meta-build systems, like
  CMake, that can output build-direcives for several build systems.
* Some are defined as programs, like Janet-projects for example.
* yet others, probably.

The build process/system/configuration can give lot of hints with regards to
which _dependencies_ are required.

### There are many existing package-repositories

To name a few, generally, high-quality sources of inspiration:

* [FreeBSD Ports](https://www.freebsd.org/ports/) [Index](https://www.freshports.org/)
* [Arch Linux](https://wiki.archlinux.org/index.php/Official_repositories)
* [Arch Linux AUR](https://aur.archlinux.org/)
* [Alpine Linux](https://pkgs.alpinelinux.org/packages)
* [NixOS](https://nixos.org/nixos/packages.html)
* [Guix](https://guix.gnu.org/packages/)

Etc. etc.

### There might be several source archives for the same release of a package

And it might be the case that one of the archives contains build configuration
whereas the others do not, so it might be worth it to download each `*.tar.gz`
and compare whether one or the other has or has not included the build
configuration.

### When the build fails. Diagnostics!

#### Logging output

`strace` can be helpful sometimes in diagnosing issues.

For example, you can try the following:

```sh
sudo strace -f \
            -u $USER \
            -o pkgname.trace \
            -- hermes build -m pkgname.hpkg -e pkgname 2> pkgname.log
```

`-f` is for tracing child processes
`-u` specifies the user to run the command as
`-o` writes the trace output to a file, `pkgname.trace`

Then you can look for (sometimes substrings of) received error messages within
the resulting `pkgname.trace`.

Note that the `trace` files often contain a lot of information. (`grep` or `rg`
is useful for searching throught them)

`pkgname.log` can sometimes be helpful to look through as well.

#### Debugging the `hpkg`

In multi user mode, we typically don't get interactive access to files and
directories, but to diagnose problems we need to check output of commands or
check log files etc.

We can get REPL access by doing something like the following:

1. edit the .hpkg file to contain an invocation of:

  `(repl nil nil (fiber/getenv (fiber/current)))`

  within the relevant builder function, say after a form that's an invocation of
  configure (e.g. `(sh/$ ./configure ...)`)

2. invoke the hermes build as follows:

  `hermes build -m pkgname.hpkg --debug`

  the result should be a REPL at which one may evaluate janet forms. To get access
  to a shell, you can try:

  `(os/execute ["/bin/sh"])`

  N.B. in this case `/bin/sh` would need to be in the `PATH` of the environment.

Note: using `rlwrap` makes the REPl interaction nicer, e.g.
`rlwrap hermes build -m pkgname.hpkg --debug`
