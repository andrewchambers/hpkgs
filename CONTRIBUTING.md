# So, you want to contribute `hpkg`s?

Great! The more, the merrier. However, there are some things that are good to
keep in mind.

## As lean as possible

Generally, the fewer dependencies an `hpkg` has, the better. That is, a package
should not import more packages than just enough. This poses the question,
though; how should we handle configurable dependecies? For example `nginx` needs
the `pcre` package for URL-rewrite functionality. In such cases, until the need
arises to do otherwise, you can err on the side of default, so import the
packages needed for the default configuration. When it becomes necessary to
repackage an existing `hpkg` in another configuration, the existing can be copied
and suffixed appropriately for easy identification.

## New packages are added via PRs

If you have an `hpkg` you would like to add, please open a PR with, at least,
either "Add" or "Update" and then the package's name in the title. If it is an
Update, then it is required to add in the description _why_ the package is
updated. Otherwise, the description is optional.
