# Things: an inventory in the manner of ZIL

Most books remember only story facts. A book may also give its hero **things**:
objects that lie in places, are picked up, carried, held and used, after the
objects of Infocom's ZIL. [books/countdown](../books/countdown/) («Обратный
отсчёт») is the worked example: Superman's powers are things he starts with, the
cable and the grenade lie in the Star 7 room, the Fortress hands him a sprayer,
and the red sun takes two powers away.

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
- Author scene-specific `.item_texts` for powers and investigative tools: what
  can be heard here, what the scan reveals now, why a forceful action would
  endanger these people. Keep the response within the camera's reading area.
  Use `.requires`/`.excludes` for mutually exclusive fact variants, so a scan
  already performed acknowledges its result. General item descriptions are
  the fallback, not a substitute for the scene's authored response.
- Taking a thing is an ordinary choice under its anchor ("Взять кабель?"). The
  next page should show the thing gone from where it lay.

## In the C table

```c
enum { CABLE = 1u << 0, HEAT = 1u << 1 };
static const struct StoryItem items[] = {
    {.item = HEAT, .id = "heat", .name = "Тепловое зрение", .carried = true, .text = "…"},
    {.item = CABLE, .id = "cable", .name = "Кабель", .where = "lab", .text = "…"},
};
/* on a decision page in the "lab" location */
{.label = "Взять кабель?", .anchor = "cable", .target = "star-cable", .take = CABLE},
{.label = "Связать их кабелем?", .anchor = "mercs-group", .target = "star-lasso", .with = CABLE},
/* on pages */
.gives = SPRAYER, .removes = CABLE,
/* in a check */
{.id = "trap", .kind = STORY_CHECK, .holds = CANISTER, .next = "…", .otherwise = "…"},
```

- `.where` names the location the thing starts in (a page `.location`);
  `.carried` gives it to the hero at the start; neither means a page will
  `.gives` it later.
- A `.take` choice is offered only while the thing lies in the page's
  location. A `.with` choice is offered only while the reader holds that thing.
  Both can also use `.requires` and `.excludes`.
- `.gives` and `.removes` move things when a page is shown; a check's `.holds`
  tests what is carried. "Try again" restores the facts and every thing's place
  as they were at that decision.
- A thing's `.id` is its scene anchor where it lies, and its icon is the
  picture for camera `item-<id>` (`illustrations/item-<id>.png`, else
  `rooms/item-<id>.jpg`). Render the icons from a small `items.blks` scene of
  close-up cameras.
- Write the `.text` as one or two short sentences that say what the thing is
  and hint at its use; it replaces the page prose while held, so it must fit
  every room camera's reading area.

## Rules

- Every use is a decision with a distinct outcome, set up in the text or the
  picture before the reader tries it.
- Do not hide the only way forward behind an unexplained use. When a page
  needs a thing (the press pass at the gate), say so in the text, and offer a
  plain choice beside it.
- Things that are used up should be removed with `.removes`; things that are
  lost and found again (powers under the red sun) are removed and given back
  by pages that say so.
