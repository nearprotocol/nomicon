# Nearnomicon https://nearprotocol.github.io/nomicon/

Implementation details of the NearProtocol client.

## Installation

```sh
cargo install mdbook
```

## Modifying the content

MdBook can automatically rebuild the content when it detects the changes. Run the following from the root to rebuild automatically:

```sh
mdbook watch
```

To force rebuild run:

```sh
mdbook build
```

To serve the mdbook while editing it, run:

```sh
mdbook serve
```

## Adding new chapters
Adding new chapters requires updating `src/SUMMARY.md` file.

## Latex
See [mdBook and MathJax](https://rust-lang-nursery.github.io/mdBook/format/mathjax.html) for using Latex.
