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
| Суперслух (hearing) | carried | the engine cab | — |
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
