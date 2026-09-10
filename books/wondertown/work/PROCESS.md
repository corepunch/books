# Book interaction and image workflow

The engine is one `main.c`. It starts the selected adventure through zilscript
and resumes its coroutine from C. ZIL supplies state, prose, object verbs and
exits. There is no Wondertown Lua manifest, XML page or camera export step.

The room page displays `{room-id}-look.jpg` and the room's available objects and
exits. Clicking an object submits its examine command and focuses it using
`{room-id}-examine-{object-id}.jpg`, falling back to the room image. Focus choices come from the
VM's verb metadata. Selecting a choice submits an ordinary parser command and
shows the response with Continue. Action art tries `{room-id}-{verb}-{object-id}.jpg`,
then object art, then the current room. Back leaves focus without executing a
story command. Typed parser input remains available for compound interactions.

All runtime art and camera/anchor source files live in
`books/wondertown/rooms/`. Scener does the rendering offline. Named cameras and
anchors in `.blks` are only used to project circles over those JPEGs. The C
host scales the image and anchors together, using actual image dimensions.

Read [RENDERING.md](RENDERING.md) for build/render commands and
[SCENE_COMPOSITION.md](SCENE_COMPOSITION.md), [ARTSTYLE.md](ARTSTYLE.md) and
[CHARACTER_DESIGN_BIBLE.md](CHARACTER_DESIGN_BIBLE.md) for artwork criteria.
The archived prototype documents describe previous experiments, not current
runtime requirements.
