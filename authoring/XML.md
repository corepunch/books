# The book XML

A book is `books/<name>/title.xml` plus one `books/<name>/locations/<id>.xml` per
location. The model follows the Virtual Cinema database of *The X-Files Game*
(HyperBole, 1998): a title holds nodes (chapters) of locations; a location holds
viewpoints of views; characters, conversations, icons, variables, enable flags,
triggers and actions are the same things, under the same names.
`src/storyxml.c` reads the files; `src/story.c` validates and plays them;
`build/cli/book` checks, measures, queries and plays them. Every unknown
element, attribute or name stops the book with its file and line.

| X-Files class | Element | Count in *The X-Files Game* |
|---|---|---|
| VCTitle | `<title>` | 1 |
| VCNode | `<node>` | 13 |
| VCLocation | `<location>` (its own file) | 44 |
| VCViewPoint | `<viewpoint>` | 347 |
| VCView | `<view direction>` | 1657 |
| VCNav | `<nav>` (an anchor, or a picture edge for turning) | 3911 |
| VCExplorable | `<explorable>` | 401 |
| VCCharacter | `<character>` | 28 |
| VCCharView | `<charview>` | 130 |
| VCConversation | `<conversation>` | 441 |
| VCIdeaMap | `<conversation with="idea">` | 59 |
| VCInventory, VCEvidenceIcon, VCIdeaIcon, VCEmotionIcon, VCActionIcon | `<inventory>`, `<evidence>`, `<idea>`, `<emotion>`, `<action-icon>` | 30, 25, 34, 14, 44 |
| VCVariable (bool, int, char), VCString | `<variable type>` | 902, 11 |
| VCEnabled | `id` + `enabled`, `<enable>`, `<disable>`, `enabled()` | 3115 |
| VCTrigger (enter, leave, end) | `<trigger event>` | 5393 |
| VCAction: SetVariable, SetEnabled, GoTo, PlayAssets, ShowInterface, CallScript | `<set>`, `<enable>`, `<goto>`, `<asset>`, `<show>`, `<script>` | 14247 |
| DoActionList | `<actionlist>`, `<call>` | 176 calls |
| VCAssetRef (a clip slice, a loop) | `clip`, `from`, `to`, `loop` | 6410 |
| VCPDANotes, VCEmail, VCPhoto, phone numbers | `<note>`, `<email>`, `<photo>`, `<phone>` | — |
| VCIFaceLayout, VCInterfaceItem | `<interface>`, `<item>` | 278, 2828 |
| EndGame | `<ending kind>` | 14 calls |

Mouse-over events and cursor shapes have no equivalent on a touch screen. The
reader runs no named engine scripts (`<script>` is kept for tools).

## title.xml

```xml
<title name="salt" start="visit" fmv="true" continue="Continue" retry="Try again" restart="Start over">
  <variable id="seen">Thomas stood under the streetlamp</variable>          <!-- bool, false -->
  <variable id="goons" type="int" initial="4">men at the barricade</variable>
  <variable id="view-state" type="char" initial="a">a default, t tan, d dark</variable>
  <variable id="cook-phone" type="string" initial="206-555-0182"/>

  <character id="penry" name="Abel Penry">The board-keeper.</character>

  <inventory id="ledger" name="Ledger" where="shack">Thomas's name, and an hour.</inventory>
  <evidence id="peg" name="Peg">A board peg cut VOSS.</evidence>
  <idea id="hour" name="The hour" carried="true">Thomas's hour.</idea>
  <emotion id="calm" name="Calm" carried="true">Say it calmly.</emotion>
  <action-icon id="badge" name="Badge">Show the badge.</action-icon>

  <note id="berth" title="Berth four" enabled="false">Thomas kept the tide.</note>
  <email id="wong" from="Cook" title="Background" enabled="false">No record.</email>
  <photo id="lamp-man" camera="window" title="The lamp" enabled="false">The man under the lamp.</photo>
  <phone number="206-555-0182" target="cook-call" if="met-cook"/>
  <interface id="pda" title="PDA"><item label="Notes" target="notes-view"/></interface>

  <node id="act-1" name="Act 1: the runaway train">
    <trigger event="enter"><set var="day" value="1"/></trigger>
    <location id="train"/>
    <location id="gorge"/>
  </node>
</title>
```

- `start` names any page. `fmv="true"` makes the picture the page: views,
  shots and endings draw no prose, and Continue exists only on a document.
- Icons are what the reader carries and holds. Holding one offers only its
  uses. A view's row shows carried inventory and evidence; a charview's row
  shows every carried icon, so ideas, emotions and action icons are used in
  conversation. An icon's picture is camera `item-<id>`.
- Records start disabled unless `enabled="true"`; `<enable target="berth"/>`
  delivers a note, an email or a photo.
- A book with any record gives every view and map a PDA, a disc beside the
  carried icons. Its home lists Notes, Email and Photos with their counts
  (unread ones marked new), the Phone, and each interface an action has
  shown. Notes and email open as documents over the view; a photo opens on its
  own camera still, captioned. The phone is a keypad: dialling a declared
  number, enabled and with its `if` holding, goes to its target page; any
  other number is not answered. An interface lists its enabled items as lines;
  choosing one runs its actions and goes to its target, putting the PDA away.
  The PDA is not offered in a conversation.
- Every location file is listed in exactly one node, in reading order.

## locations/&lt;id&gt;.xml

```xml
<location id="office" name="The office">
  <trigger event="enter">…</trigger>        <!-- arriving from another location -->
  <trigger event="leave">…</trigger>

  <viewpoint id="desk-spot">
    <view id="desk" camera="office" direction="n" clip="window" loop="true" sets="read">
      <text>The desk, the lamp, the telephone.</text>
      <trigger event="enter"><set var="visits" add="1"/></trigger>
      <holding icon="ledger" if="glimpsed">What the ledger shows here.</holding>
      <explorable label="The folder" anchor="folder" target="folder"/>
      <explorable id="lamp" label="The lamp" anchor="desk-lamp" target="lamp-shot" enabled="false"/>
      <explorable label="The telephone" anchor="phone">
        <enable target="lamp"/>
        <give icon="peg"/>
      </explorable>
      <explorable label="The ledger" anchor="book" take="ledger" target="desk"/>
      <nav label="Turn right" edge="right" target="window-side"/>
      <nav label="The door" anchor="door" target="wharf" if="read and not left"/>
      <charview id="edith" character="edith" anchor="locket" label="Edith" camera="visit" target="edith-greet">
        <text>Edith waits.</text>
        <conversation id="ask-thomas" label="Thomas?" if="not talked" clip="edith-thomas" sets="talked">
          "He kept the tide," she says.
        </conversation>
        <conversation id="ask-hour" label="His hour" with="hour" clip="edith-hour" from="1200" to="5400">
          "Read it here."
        </conversation>
        <conversation label="Calmly" with="calm" target="calm-list"/>
        <conversation label="Goodbye" ends="true" target="desk"/>
      </charview>
    </view>
    <view id="window-side" camera="visit" direction="e">…</view>
  </viewpoint>

  <asset id="folder" camera="office-file" read="true" next="desk">
    A document. A blank line starts a paragraph,

    and <region/> moves the rest into the camera's second reading region.
  </asset>
  <asset id="lamp-shot" camera="office-lamp" clip="lamp" next="desk">
    <trigger event="end"><if test="mood == 't'"><goto target="ending-tense"/></if></trigger>
    A shot: the clip plays, then next.
  </asset>
  <actionlist id="calm-list">
    <if test="caller == 'Cook'"><goto target="desk"/></if>
    <else><goto target="window-side"/></else>
  </actionlist>
  <map id="harbour-map" camera="harbour">
    <text>The harbour from the hill.</text>
    <destination label="Berth four" anchor="berth" target="wharf"/>
  </map>
  <ending id="ending-tense" kind="failure" camera="window" retry="desk">The lamp goes out.</ending>
</location>
```

### Pages

- `<view>`: a still with circles. In a `<viewpoint>`, views are the
  directions a reader can face from one spot; `<nav edge="left|right|back">`
  turns between them on the picture's edge. A `loop="true"` clip plays
  behind the circles.
- `<charview>`: a character in frame, with conversation lines in a band and
  one `ends="true"` line per icon the reader may hold there. Inside a view it
  is also that view's circle on the character (`anchor`, `label`, and a
  `target` such as a greeting shot; without one, the circle opens it).
- `<conversation>`: a line. With prose or a clip it has a reply, a page with
  its own `id`, that plays and returns to the charview (or goes to `next`).
  Without, it leads to `target` or runs the actions inside it. `with` offers
  it only while that icon is held: a topic, a tone, a gesture.
- `<asset>`: a shot (fmv) or a passage; `read="true"` is a document.
  It goes to `next` when it ends, after its end trigger.
- `<map>`: travel. Its `<destination>` circles lead to views anywhere.
- `<actionlist>`: invisible; its actions must go somewhere when a choice
  leads to it, and `<call list>` runs it from any action block.
- `<ending kind="success|partial|failure">`: failure and partial retry from
  the reader's last view, or `retry`, with the world as it was there.

Every shown page has a `camera` and prose (`<text>` on views, charviews and
maps; the element's own text elsewhere). `clip` names
`books/<name>/clips/<clip>.mp4`, played in the picture with the still as the
poster; `from` and `to` (milliseconds) play a slice.

### Choices

`<nav>`, `<explorable>`, `<destination>`, a charview's circle and
`<conversation>` lines share these attributes: `label`, `anchor` (or a nav's
`edge`), `target`, `if`, `with`, `take` (explorables only), and `id` with
`enabled="false"` for a choice that starts disabled. Actions inside run when it
is chosen; a `<goto>` among them overrides `target`, and without either the
reader stays and the page shows what changed.

### State

- `if` and `test` are conditions: `seen and not left`, `goons >= 2`,
  `view-state == 't'`, `cook-phone == '206-555-0182'`, `has(ledger)`,
  `holding(badge)`, `enabled(lamp)`, `visited(alley)`, with `and`, `or`,
  `not` and parentheses.
- `sets="a b"`, `gives="x"` and `removes="x"` on a page are its first enter
  actions.
- Actions: `<set var value|from|add>`, `<enable target>`, `<disable target>`,
  `<give icon>`, `<remove icon>`, `<goto target>`, `<call list>`,
  `<if test>…</if><else>…</else>`, `<show interface>`, `<hide interface>`,
  `<script name args>`.
- Triggers: `enter` and `leave` on nodes, locations and pages, `end` on
  assets and conversation replies. Entering a node runs before entering its
  location; leave triggers cannot go anywhere.
