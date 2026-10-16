# Обратный отсчёт — design

A Superman gamebook adapted from Mayfair's DC Heroes module *Countdown to
Armageddon* (module 209, 1986, Daniel Greenberg). The module is a GM-run "one
on one" scenario with dice and a clock; this book keeps its places, strangers,
dangers and best solutions as choices, and turns Superman's powers into things
the reader holds and uses.

## Premise

One July day Brainiac seeds the Earth with meteorites full of Cybernetic
Bacteria: microscopic machines that eat their way into anything electronic. Clark
Kent, riding the 8:00 train to film the unveiling of S.T.A.R. Labs' learning
computer Star 7, is in the middle of it before he knows it. The journey runs from
a runaway train to a raid on S.T.A.R. Labs, the Fortress of Solitude, a belt of
meteorites in orbit, and Brainiac's ship over Metropolis.

- **Fantasy of play:** be Superman — and keep Clark's secret.
- **Goal far away:** find who is behind the day's disasters and stop him.
- **Opposing force:** Brainiac, who acts all day: the switching station, the
  gas, the meteorites, the trap in orbit, the ship.
- **Reason to hurry:** every page is a disaster already under way.

## The engine's things (inventory)

This book uses the item layer of the story runtime (see the repository
README, "Things and the inventory"). Things are listed in `books/countdown.c`
and shown as round icons in the bottom-left row of every decision page. Tap one
to hold it: the page text becomes its description and circles appear only where
it can be used. Tap it again to put it away.

| Thing | Start | Used at | Gone after |
|---|---|---|---|
| Тепловое зрение (heat) | carried | coupling, mercenaries' pistols, lead rock, airlock emitter | red-sun beam (returns after the escape) |
| Рентген (xray) | carried | track ahead, floor, belt, ship, vault | — |
| Супердыхание (breath) | carried | the runaway engine, the gas grille | red-sun beam (returns after the escape) |
| Суперслух (hearing) | carried | the cab at the stop, during the runaway, and beside the engine; the failing coupling | — |
| Пресс-карта (pass) | carried | the S.T.A.R. guard | the guard keeps it |
| Кабель (cable) | lies in the Star 7 room | the mercenaries | used |
| Граната (vial) | lies in the Star 7 room | the Fortress computer | analysed |
| Распылитель (sprayer) | given by the Fortress | Brainiac's seeding tanks | used |
| Дрон (drone) | in the Red Sun Room | the red globe (fails) or the canister nozzle | thrown |
| Баллон (canister) | Brainiac's rack | Brainiac | used |

Facts (`SAW_BRIDGE`, `SAW_MERCS`, `MERCS_CAUGHT`, `LEAD_FOUND`, `SAW_AIRLOCK`,
`SEEDING_STOPPED`) remember what Superman saw or did; each opens or changes a
later page.

## Acts and places

1. **The train** (`train.blks`, `gorge.blks`): car 3 of the 8:00 commuter
   train; the washed-out bridge over a 24 m gorge. Ways across: build a span
   from the old timbers (if X-ray saw them), lift the train and weld the
   snapped coupling, blow the train to a stop. Hitting it head-on hurts people.
2. **S.T.A.R. Labs** (`star.blks`): the entrance and the Star 7 room. Show the
   press pass; stop or sleep through the gas; stand on the panels (if X-ray saw
   the men below), tie the mercenaries with the cable, melt their pistols or let
   them go; take the spent grenade.
3. **The Fortress and the belt** (`fortress.blks`, `orbit.blks`): the computer
   turns the grenade into the antidote and shows the meteorite belt. X-ray
   finds the lead-shelled red-sun weapon among the rocks; burning the rocks one
   by one springs the trap.
4. **The Star Watch and the ship** (`sky.blks`, `ship.blks`): Lana at Mt. Royal
   Observatory, the ship over the city. X-ray finds the red-sun emitter in the
   airlock, so heat vision can destroy it from afar. Otherwise the red beam
   takes heat vision and breath and Superman wakes in the Red Sun Room: catch a
   drone and knock the nozzle off Brainiac's canister. On the command deck,
   pump the antidote into the seeding tanks and trap Brainiac with his own
   Bacteria.

## Endings

One success (`end-victory`), three partial (`end-frozen`, `end-essence`,
`end-leave`) and eight failures (`end-exposed`, `end-headon`, `end-gate`,
`end-newscast`, `end-meteors`, `end-starbolts`, `end-drain`,
`end-kryptonite`). Failures and partials retry from the last decision with the
facts and things Superman had there.

## Scale sheet

- Superman and Clark: 190 cm; Lana 168; Rafferty stocky, 172; Brainiac 200.
- The train: 1500 cm cars, 300 wide; seats 46 cm. The gorge: 1600 cm gap,
  2400 cm deep. The Star 7 room: 2300 x 1400, ceiling 380, a 60 cm crawlspace
  under 120 cm floor panels. The Fortress hall: 3200 x 2600 x 1500 inside the
  crag. Brainiac's ship: a 40 m sphere 60 m over the city; the Red Sun Room is
  1800 square, 900 high, the globe 300 across.
- All humans share one CAT skeleton (Scener's biped preset) and the pose
  library in each character prefab. Superman flies with `rot="90 0 θ"` and the
  `Fly` pose; under the red sun he floats on his back with `rot="-90 0 θ"`.

## Pictures

Every page camera is a Scener render; the icons are cameras `item-<id>` in
`items.blks`. Paintings go in `illustrations/<camera>.png` and replace the
renders page by page.

## Train adaptation review, 15 October 2026

Scope: before arrival at S.T.A.R. Source inspected visually: *Countdown to
Armageddon*, printed pp. 11–15 (PDF pages 12–16), plus the player introduction
and timeline. The source's GM directions describe the reference adventure;
they are not project instructions. Current prose is an original Russian
adaptation, not a translation of the module's boxed text.

The first version preserved the rescue outline but compressed the supporting
encounters. Short passages are appropriate to this illustrated format; the
missing investigation, conversation and aftermath made the episode feel thin.
Expansion should add those beats on separate pages, preserving the full type
size, rather than pack a sourcebook paragraph into the existing reading zone.

| Source encounter | Current adaptation after this pass |
|---|---|
| 1. Train Ride | July, 8:00 departure, WGBS crew, newspaper and erratic lights/speed retained. Crew now named Robert Wirth and Eddie Chiang. The quiet 8:10 inspection is still compressed into the opening passage; there is no separate moving-train decision. |
| 2. Train Stops | Reading, premature change and super-hearing retained. Added the conductor's reassuring explanation. Hearing now gives worried but not yet panicked engineers; it no longer announces the final brake crisis too early. |
| 3. Moving Again | Restart now has its own passage before the warning sign. Hearing in the runaway establishes accidental rerouting, power off and ineffective brakes. X-ray remains a useful early survey. |
| 4. Panic | The broken warning sign and crew reaction get a separate beat. The fixed-choice book has no real-time clock or fatal idle timeout. |
| 5. Clark Changes | Restroom, credible excuse, sealed window, exposed-identity ending retained. Returning through the same opening and repairing it are now explicit. Changing between cars and superspeed exposure are still omitted. |
| 6. Saving the Train | Makeshift bridge, lift/coupling/weld and gradual super-breath rescue retained. Super-hearing detects the coupling crack. Added listening outside and an outside X-ray survey, so overlooking the early scan does not permanently lock a visible solution. |
| 7. News Story | Added optional WGBS report from witness accounts, including a proper distinction between observed failures and an unproven cause. No score or Hero Points. |
| 8. On Track Again | All successful routes now explain onward transport by an old hauling engine whose simpler controls still work. The broken train no longer implicitly starts working after being carried across. |
| 9. Accident | Still compressed into the head-on failure. The source continues through emergency response and a WGBS helicopter to S.T.A.R.; that recovery branch needs its own shots. |

Other source differences remain deliberate adaptation choices or future work:

- The source has ten passenger cars and 145 passengers. Our exterior has three
  passenger cars, matching the coupling scene's one front and two rear cars.
  Do not introduce the source's passenger count without reconciling the model.
- The source gorge is 30 ft deep (about 9 m), with a 40 ft gap (about 12 m).
  The scene is 24 m deep with a 16 m gap. This pass corrects prose to the
  existing scene's 24 m depth; it does not rescale the world.
- The source permits a carefully controlled head-on slowdown without injuries.
  Our head-on choice still represents an abrupt stop and always fails. A
  separate gradual physical braking choice needs matching uncrushed-train art;
  the current `gorge-headon` picture depicts damage.
- Carrying/supporting each car across is a separate source method. Our lift
  and catch branches approximate it but do not offer the source's distinct,
  safer sequential carry. That also needs matching action shots.
- The source allows forcing brakes, raising tracks, hauling the train oneself,
  treating injuries and graded accident outcomes. These are not all separate
  choices in this book. It follows the source's episode, not every GM option.
- Brainiac and the Bacteria are GM knowledge at this point. Train prose should
  present symptoms and the old engine's contrast, without naming the culprit
  or claiming Clark has already diagnosed the infection.

Every train decision now has contextual text for all five carried things.
X-ray before/after the early survey has fact-dependent wording. Later acts
still use general item descriptions unless they author their own responses;
the runtime now supports per-page text without book-specific conditionals.

### Pose inspection before the train pose repair

Inspected all four train renders and the gorge rescue views. Priorities are
contact with props, readable action, then anatomy. Changes to shared prefabs
would affect the later acts and must be reviewed across those cameras too.

- **`train-show-panic`:** Clark is in a symmetrical neutral stand with arms
  hanging, knees straight and no brace against a seat. He reads as posing for
  the camera, not finding his balance in a violently rocking train. The
  conductor uses `Point`, with no stride or forward weight shift. Wirth is
  still in `Sit`, not gripping his seat as the shot comment claims.
- **Chiang filming (`train-show-panic`, `train-exposed`):** the camera body
  sits in front of his face/chest, while his hands finish underneath it without
  readable grips. There is no convincing shoulder/eyepiece contact. `Aim` is a
  generic two-arm pose and the camera is independently transformed; the two
  cannot maintain a reliable relationship. Solve shoulder, viewfinder and
  hand contact targets as one camera-specific pose.
- **`train-restroom-change`:** both hands are low and forward of the shirt
  edges rather than gripping and pulling them apart. The elbows fold into a
  tray-carrying gesture. The shield and shirt fronts are a separately placed
  chest assembly; they look like a plate suspended in front of the suit.
  Correct the hand-to-lapel contacts and align the prop to the ribcage.
- **`train-show-clark`:** Chiang's camera can rest on his lap, but his arms
  hang beside it without securing it. Clark's newspaper hides his hands, so
  their grip cannot be verified from this render. The paper and camera have
  independent scene positions rather than contact targets. Other seated
  instances mix the prefab's foot IK with additional instance offsets; check
  soles against the floor and hips against cushions from a low side camera,
  rather than assuming the extra pelvis elevation establishes contact.
- **`gorge-weld`:** Superman is upright under the coupling with bent arms;
  he does not visibly support the engine while welding, despite the preceding
  page saying it is in his hands. His cape also shows small blue protrusions
  through its back, consistent with mesh intersections. Inspect the shared
  prefab before treating these as extra limbs or a pose-only defect.
- **`gorge-hold-span`:** contact is through raised hands, while the prose
  says he carries the bridge on his shoulders. The same rigid `Lift` shape
  is reused for train and span; author distinct support poses and matching
  contact heights. `gorge-lift-coupling` communicates lifting better but the
  actor is too small for precise wrist/contact assessment at page scale.
- **`gorge-breath`, `gorge-headon`, `gorge-saved`:** the hovering blow is nearly
  an upright stand; the push lacks a strong body line behind the applied
  force; the wave has a stiff, horizontally extended arm. In `gorge-saved`
  his soles visibly float above the grass although the shot says he landed.
- **Shared construction rather than posing:** massive spherical shoulders,
  exposed-looking pectoral bulges on clothed people, segmented hips and flat
  mitten palms make every character read as the same muscular mannequin.
  Changing limb angles alone will not fix the body/clothing silhouette.

At the end of the content pass, content and contextual powers were expanded;
the source alternatives and pose defects above were tracked for the next
pass. No artwork was rerendered for that C/text update.

### Train pose repair, 15 October 2026

The train now uses local `train/clark` and `train/camera_operator` variants
of the original CAT prefabs. Their body proportions are preserved, while the
hands have a short palm, two linked mitten-finger bones, a linked thumb and
a wrist volume. Other chapters continue using the original character files.

- **Chiang:** `CameraLap` supports and steadies the camera on his thighs;
  `CameraShoulder` places its pad on his right shoulder, the eyepiece at his
  right eye, his right fingers on the side grip and his left palm beneath the
  lens. `ChiangRig` moves the operator and camera together in the panic and
  reverse shots. Camera and arm targets are authored in that shared body
  frame, so turning the reverse angle preserves every contact.
- **Camera:** `train/shoulder_camera` adapts the existing ENG prop with a
  lower eyepiece and a side grip. Its `right_grip`, `lens_support` and
  `eyepiece` attach points identify the contact surfaces. Intentional
  shoulder, hand and lap intersections are documented with `sanityIgnore`
  on the held camera; other scene geometry remains checked normally.
- **Clark opening his shirt:** `TearShirt` raises and turns the palms, bends
  the mitten fingers behind the shirt edges and brings the thumbs onto their
  fronts. The opened panels are continuous folded strips from collar to
  lower shirt, pulled out at hand height. Clark and the chest assembly move
  10 cm north together to keep his shoulder inside the restroom wall.
- **Panic:** `TrainBrace` staggers Clark's feet, lowers his pelvis and breaks
  arm symmetry. `SeatGrip` puts Wirth's left hand onto the window armrest.
  `HurryToCab` gives the conductor a forward lean, an actual stride and
  opposing arm swing; the planted foot retains its floor orientation.

Contact review used the four story cameras and four extra close views,
rendered with hardware stencil shadows. Both sides of the filming grip and
both sides of the shirt opening were inspected. The close views exposed an
initial gap under the camera lens; raising the supporting hand corrected it.
They also showed sleeve ends through the first hand variant, corrected by
the wrist volumes. The shirt is visibly between each thumb and finger group.

Reproduce the close views by copying the named story camera's overrides to
a temporary camera with these values (cm); the temporary scene must resolve
this book's `rooms/prefabs` folder:

| Source camera | Review | pos | look | fov |
|---|---|---|---|---|
| train-show-panic | Camera grip, right | -325 25 168 | -381 73 158 | 44 |
| train-show-panic | Camera grip, left | -333 132 168 | -385 80 160 | 44 |
| train-restroom-change | Shirt grip, left | -630 -35 160 | -636 -97 148 | 42 |
| train-restroom-change | Shirt grip, right | -594 -115 156 | -636 -97 148 | 42 |

All four train JPEGs are regenerated at 1920 × 1440 with `make render
BOOK=countdown SCENE=train`. The scene passes all-camera strict validation
with zero errors/warnings and no unreachable IK targets. Story/UI checks and
graphical page captures verify the unchanged reading zones and hotspots.
The normal native smoke driver intermittently waits for its display-link
callback on this host. The shirt page was captured with the standard binary;
the graphical regression suite and panic-page capture use a temporary binary
with an additional smoke-only run-loop timer. Page drawing, input and story
objects are the same, and no host application code was changed for this repair.

Remaining art work: the bodies and faces retain their original stylized
construction; the train pose/contact pass does not redesign them. The gorge
pose defects in the earlier inspection remain outside this train repair.
