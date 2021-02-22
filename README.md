# slowcopy
A command line utility to copy a file at a limited speed. Useful for server reliability benchmarking and for preventing overheat in high-bandwidth/high-throughput storage solutions.

# Installation

```bash
npm install -g slowcopy
```
# API & Usage

```
  Usage: slowcopy [options] <source> <destination> <speed-limit>

  A command line utility to copy a file at a limited speed.

  Options:

    -h, --help     output usage information
    -V, --version  output the version number
    -f, --force    Force over-write if destination already exists
    -q, --quiet    No non-error output
```


# LICENCE

[MIT](LICENSE)

