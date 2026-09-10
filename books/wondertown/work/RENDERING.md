# Offline artwork with Scener

Book uses the pre-rendered JPEGs in `books/wondertown/rooms/`. `main.c` reads
that directory's `.blks` camera and anchor metadata for projection only.
No native Orca exports or runtime scene rendering are involved.

From the engine root:

```sh
make render BOOK=wondertown SCENE=workshop-new WIDTH=1920 HEIGHT=1440
make layout BOOK=wondertown SCENE=workshop-new
make run BOOK=wondertown
make check
```

Scener renders every named camera; each camera name becomes its JPEG filename.
Use `{room}-look` for overview cameras and `{room}-{verb}-{object}` for
focus/action cameras, with lower-case hyphenated ZIL IDs. Keep JPEGs and scene metadata at
the same revision. C reads actual image dimensions and applies the same
centered crop to the image and hotspots. Shared rooms can occupy one `.blks`
scene. Camera names must be unique across the book's active scene files.

`tools/render.py` renders to a temporary directory and checks that every camera
produced an image before replacing existing JPEGs. `make run` uses existing
artwork and does not invoke Scener. `layout.jpg` is a development image.

Scener lives at `~/Developer/mapview/ui/apps/scener`, with build root
`~/Developer/mapview/ui`. Read that checkout's `AGENTS.md` and Scener `CLI.md`
before edits. Build and deploy from the UI root:

```sh
make build/bin/scener
python3 apps/scener/deploy.py --prefix "$HOME/.local"
```

Set `SCENER=/path/to/scener` when needed. Keep the launcher and runtime libraries
together. Rendering needs a working desktop GPU context; software rendering
on macOS has produced incorrect shadows. Inspect final-size images, camera
sequences and Book's real UI. Do not fix image composition in the host renderer.

The workshop source generator is
`books/wondertown/work/tools/build_workshop_new.py`. It rebuilds the authored
scene and furniture prefabs in `books/wondertown/rooms/`. Historical experiments
and the retired Orca workflow are retained in `archive/` as references.
