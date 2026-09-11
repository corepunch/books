# Scener references and final AI illustrations

Scener's output is a reference for AI to draw over. It establishes the camera,
room layout, object inventory, rough silhouettes, scale, occlusion and shadow
direction consistently across many views. Simple boxes, cylinders and broad
color regions are appropriate when they identify an object. These renders are
not the final visual quality target.

The AI illustration pass adds the storybook finish from [ARTSTYLE.md](ARTSTYLE.md):
materials, wood grain, wear, cloth, picture contents, fine fittings, dust,
sawdust, small shavings and atmosphere. It preserves the reference perspective,
object footprints and proportions, spatial relationships, openings and motivated
lighting. Use adjacent approved views and character references to maintain the
same designs across shots. A new permanent object needs a proxy in the shared
scene before it appears in final images; texture detail does not.

For each scene, keep a short illustration handoff in its design brief identifying
rough proxies and required painted-only content. An interaction such as SAWDUST
still needs its ZIL anchor and focus camera even when its particles are not
modelled. Its final painted footprint must cover that anchor in every relevant
view. Check the final AI images with the actual hotspot/UI overlay as well as
the raw references.

Book uses the pre-rendered JPEGs in `books/wondertown/rooms/`. `scene.c` reads
that directory's `.blks` camera/anchor metadata for projection and reading regions.
No native Orca exports or runtime scene rendering are involved.

## Per-camera reading regions

Author a flat image-space rectangle on the existing camera, for example:

```xml
<camera name="workshop-floor-look" pos="330 -220 345" look="-30 410 -70"
        fov="65" textRect="0.04 0.66 0.56 0.30" textScale="0.85" />
```

`textRect` is `x y width height` in fractions of the full JPEG, measured from
its top-left corner. Values must be finite, dimensions positive, and the entire
rectangle inside 0…1. It follows the same centered cover crop as the image and
anchors, then clips to the page's safe inset. Keep it inside the visible crop
on supported display shapes. These are Book metadata attributes; Scener renders
the camera normally and does not bake prose or a panel into the JPEG.

`textScale` is optional (default 1, accepted range 0.5…2), and requires `textRect`.
At a displayed image height of 800 logical points, scale 1 prefers 36-point
text. It scales with the displayed image height. Book measures the actual ZIL
passage with Literata, wraps it to the rectangle, and reduces size only as far
as 80% of the preference. Longer text scrolls inside the rectangle at that
minimum. Never shorten prose or hide circles to force a composition to fit.
Cameras without a region retain the existing top-left layout.

Text remains a flat page overlay drawn with cached glyph textures. No 3D text
plane or whole-paragraph render texture is needed. This preserves crisp text,
normal wrapping and scrolling while camera metadata controls placement.

The workshop overview is the first authored region. Inspect its native capture
with the entire introductory passage and all ten circles, leaving at least
12 logical points between the region and a circle's edge. `--headless` and
`--check` report `text_region` bounds, preferred/fitted font sizes and content
height for validation. Headless hotspots report displayed centers as `x`/`y`
and unchanged projection coordinates as `anchor_x`/`anchor_y`. Circle edges
must be separated by at least one radius (24 logical points); the host's shared
layout handles crowded anchors and keeps hit areas aligned with moved circles.
Inspect the short connector lines and their object associations too. A passing fit does not prove that the background is quiet:
inspect the render and final AI painting too. Carry the exact reading region
into the AI handoff; do not fill it with high-contrast grain, debris or new props.

## Render and review

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

Current workshop JPEGs are raw development references. `make render` does not
invoke AI and will overwrite any final illustrations at those same paths. Once
illustrated images exist, render review references with Scener's `--output-dir`
into `work/<scene>/references/` first and retain the approved illustrations until
their replacements are reviewed. Keep source references separately from final
painted outputs; only approved runtime images go into `rooms/`.

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

The workshop window uses Scener's procedural `round-arch` window, including its
matched wall cut, pane and sill. The rear door uses the procedural `door` with
an integrated pet passage and a round glazed window in its upper half.
`window="matching"` instead gives the opening the door's own profile, and
`windowPane="0"` leaves it open. `openAngle="0"` preserves the closed main-door
state; the leaf, handles, pet trim and window share its hinge when opened. Rebuild
and deploy the current Scener checkout before rendering: this source requires
door support and full-length Book camera names.

The workshop shell also requires Scener's procedural wall finishes and floors.
In the generator, `wall_finish` controls the teal lower section, plaster upper
section and oak trims: the divider is at 100 cm, with 12 cm baseboards, a 9 cm
divider and 14 cm ceiling trim. `trimSide` faces each wall's trims into the room.
The procedural door and window cut the wall sections and trims automatically;
do not restore separate panel overlays or hand-cut divider pieces.

The single `floor` replaces the backing slab and individual board boxes. It keeps
the walking surface at Z=0, with 20 cm courses and 206 cm staggered boards running
north–south, 0.3 cm joints, `colorVariation=.12` and repeatable `seed=23`.
Change `style` to `squares`, `hexes` or `stones` for other floors; omit `tileLength`
for squares and hexes. The floor owns its recessed backing through `groutMaterial`.
