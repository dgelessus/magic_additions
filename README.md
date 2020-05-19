# magic_additions

This is a set of custom "magic files" (file type identification patterns) for the Unix [`file`](https://www.darwinsys.com/file/) command, to detect some file formats that I encountered that are not recognized by default.

Many of these patterns are not very precise and may give false positives, especially for formats with no magic number or other obviously recognizable pattern. If you encounter any false positives (files recognized as an incorrect type) or false negatives (files not recognized when they should be), please open an issue or submit a PR.

## Installation/Usage

All magic files in this repo are found in the `magic` directory. To use these files, you need to place this `magic` directory on `file`'s list of magic paths, using the `-m`/`--magic-file` option or the `MAGIC` environment variable.

Unfortunately, setting a custom magic path list also disables the standard magic patterns that come included with `file`.  To use the magic files from this repo while also keeping the standard magic patterns, you need to manually include the default magic paths in your custom magic path list.

The default magic path list can be seen in the output of `file --version`. For example, on my Ubuntu 20.04 system:

```sh
$ file --version
file-5.38
magic file from /etc/magic:/usr/share/misc/magic
```

Assuming this repo has been cloned in the directory `/path/to/magic_additions`, the custom magic path list here should be `/path/to/magic_additions/magic:/etc/magic:/usr/share/misc/magic`.

If you want to use the magic files from this repo permanently, you can set the `MAGIC` variable in your shell profile/rc file. You may want to separate the default and custom magic paths for clarity, for example:

```sh
MAGIC_DEFAULTS="/etc/magic:/usr/share/misc/magic"
MAGIC_ADDITIONS="/path/to/magic_additions/magic"
export MAGIC="${MAGIC_ADDITIONS}:${MAGIC_DEFAULTS}"
```

### Compiling

`file` supports compiling a magic file (or a directory of magic files) into a binary database with a .mgc extension. This will slightly improve the performance of `file`, because loading the pre-compiled database is faster than parsing the text source files on every run.

In the case of this repo, the performance benefit is minimal, because there are very few magic files and patterns. Still, if you want to compile the magic files from this repo, you can use the included Makefile:

```sh
$ make
file -C -m magic
```

This will produce a `magic.mgc` database that contains the patterns from all magic files in the `magic` directory. After doing this you do *not* need to adjust your magic path list - `file` will automatically detect and use the compiled .mgc database instead of the source files. However, if you update the repo or modify the source files, you need to manually recompile the database using `make`.
