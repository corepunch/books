# Book

Book is a standalone interactive storybook application built on the
`corepunch/platform` runtime.

## Requirements

- macOS with Xcode command-line tools
- Lua 5.4 development files and `pkg-config`
- The platform checkout at `../../platform` relative to this repository

The platform location can be overridden:

```sh
make PLATFORM_DIR=/path/to/platform run
```

## Run

Build and launch the application with:

```sh
make run
```

Running `make` without a target does the same thing. In VS Code, press
Cmd+Shift+B to run the configured application task.

## Checks

Run the standalone story and scene checks with:

```sh
make check
```

## Repository layout

- `Standalone/` — native application and build files
- `Rooms/` — 3D room source files and rendered assets
- `Scenes/`, `Screens/`, `Scripts/` — runtime scene and interaction data
- `libs/zilscript/` — story and parser library sources

## Platform dependency

The application uses [corepunch/platform](https://github.com/corepunch/platform).
For a standard sibling checkout layout:

```sh
git clone https://github.com/corepunch/platform.git ../platform
```

