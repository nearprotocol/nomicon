# Rustonomicon

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

## Diagrams
See [mermaid.js](https://github.com/knsv/mermaid) for writing diagrams.
