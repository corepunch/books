# Things: an inventory in the manner of ZIL

Most books remember only story facts. A book may also give its hero **things**:
objects that lie in places, are picked up, carried, held and used, after the
objects of Infocom's ZIL. [books/countdown](../books/countdown/) («Обратный
отсчёт») is the worked example: Superman's powers are things he starts with, the
cable and the grenade lie in the Star 7 room, the Fortress hands him a sprayer,
and the red sun takes two powers away. The Salt Ledger carries one thing, the
harbor ledger; the case and how to continue it are in `books/salt/DESIGN.md`.

Use things when handling tools is part of the fantasy (a hero's powers, a
detective's kit, a magic bag). Keep them few — about four to eight carried at
once — and give each a reason to be used more than once or to be missed. Facts
remain the right tool for "what happened"; things are for "what the hero has".

## How the reader sees them

- Every decision page shows the carried things as round icons in a row along
  the bottom-left edge, each with its name. Keep that corner of every room
  camera free of anchors and prose, as story pages keep the lower right free
  for the Continue button.
- Tapping a thing **holds** it: the page keeps its picture, the prose becomes
  the thing's description, and circles appear only where that thing can be
  used on this page. Tapping it again puts it away. A held thing with no use
  here simply shows no circles; that is information, not a failure.
- Author scene-specific `<holding>` responses for powers and investigative tools: what
  can be heard here, what the scan reveals now, why a forceful action would
  endanger these people. Keep the response within the camera's reading area.
  Use `if` for fact variants (the first that applies is shown), so a scan
  already performed acknowledges its result. General item descriptions are
  the fallback, not a substitute for the scene's authored response.
- Taking a thing is an ordinary choice under its anchor ("Взять кабель?"). The
  next page should show the thing gone from where it lay.

## In the XML

```xml
<!-- title.xml, after the variables: inventory, evidence, idea, emotion or action-icon -->
<inventory id="heat" name="Тепловое зрение" carried="true">…</inventory>
<inventory id="cable" name="Кабель" where="lab">…</inventory>
<evidence id="vial" name="Граната">…</evidence>

<!-- a view in the "lab" location -->
<explorable label="Взять кабель?" anchor="cable" target="star-cable" take="cable"/>
<explorable label="Связать их кабелем?" anchor="mercs-group" target="star-lasso" with="cable"/>
<holding icon="heat" if="not scanned">What the heat shows here…</holding>

<!-- on any shown page, or as actions -->
<asset id="…" camera="…" gives="sprayer" removes="cable" next="…">…</asset>
<give icon="sprayer"/>

<!-- in an action list -->
<if test="has(canister)"><goto target="…"/></if>
```

- `where` names the location the icon starts in; `carried="true"` gives it to
  the reader at the start; neither means an action will give it later.
- A `take` explorable is offered only while the icon lies in the view's
  location. A `with` choice is offered only while the reader holds that icon.
  Both can also use `if`.
- `gives`, `removes`, `<give>` and `<remove>` move icons; `has(icon)` tests
  what is carried and `holding(icon)` what is held. "Try again" restores the
  variables and every icon's place as they were at that view.
- Views show carried inventory and evidence. Ideas, emotions and action icons
  appear only on charviews, where `<conversation with="…">` lines use them.
- An icon's `id` is its scene anchor where it lies, and its picture is camera
  `item-<id>` (`illustrations/item-<id>.png`, else `rooms/item-<id>.jpg`).
  Render the icons from a small `items.blks` scene of close-up cameras.
  `build/cli/book query <name> <icon>` lists every page that takes, gives,
  removes, tests or uses it.
- Write the icon's prose as one or two short sentences that say what it is
  and hint at its use; it replaces the page prose while held, so it must fit
  every room camera's reading area.
- «Обратный отсчёт» (`books/countdown/`) has ten icons: five powers, the press
  pass, and four things found on the way.

## Rules

- Every use is a decision with a distinct outcome, set up in the text or the
  picture before the reader tries it.
- Do not hide the only way forward behind an unexplained use. When a page
  needs a thing (the press pass at the gate), say so in the text, and offer a
  plain choice beside it.
- Things that are used up should be removed with `removes`; things that are
  lost and found again (powers under the red sun) are removed and given back
  by pages that say so.
