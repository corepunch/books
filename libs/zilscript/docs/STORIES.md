# Suggested Adventures for AdventureArena

Adventures are implemented in ZIL (Zork Implementation Language) via the zilscript Lua engine. Each story is designed around that format: a set of connected rooms, objects to pick up and use, puzzles with physical solutions, and NPC interactions. No animation, no licensed IP — everything is original and inspired by public domain folklore, fairy tales (Grimm, Andersen, Arabian Nights), and classic adventure conventions.

---

## For Kids

Designed for ages 6–12. Parent reads aloud; child chooses what to do next. Each adventure has 8–15 rooms, simple puzzles, a clear goal, and a satisfying ending. Inspired by themes kids already love — crafting worlds, animals, magic, space — but with original characters and no licensed content.

---

### 1. The Builder's Lost Village
**Genre:** Exploration / Puzzle
**Tone:** Lighthearted, crafty, Minecraft-spirit without Minecraft

You wake up to find your blocky home village has been stolen — lifted out of the ground overnight and scattered across the world as pieces. Each area you explore (forest, cavern, volcano rim, cloud platform) holds one missing piece. Collect materials, solve a simple puzzle in each zone to reclaim the piece, and carry everything back to rebuild. Final puzzle: assemble the pieces in the right order.

**ZIL fit:** Objects carried between rooms and placed in specific locations; a "village-complete" global flag; clock event counting down turns before "the thief returns."

---

### 2. Obby Escape
**Genre:** Action / Comedy
**Tone:** Absurd, fast, Roblox-spirit

A glitchy game portal has swallowed you and your two friends (NPCs who wander nearby). You must cross five obstacle-course zones — a lava pit room, a candy castle, a giant rolling-boulder corridor, a zero-gravity chamber, a final boss platform — solving a puzzle in each zone to unlock the exit portal. Friends give hints but can only help if you bring them the right item.

**ZIL fit:** Linear zone progression with conditional exits; NPC companions with ACTORBIT and GIVE interactions; timed atmospheric events ("Warning: lava rising!").

---

### 3. The Dragon Egg
**Genre:** Fantasy / Friendship
**Tone:** Warm, funny, wonder-filled

Inspired by dragon folklore (Brothers Grimm adjacent). A dragon egg rolls into your garden and hatches. The hatchling is lost — its parent is somewhere across the mountain range and very worried. You must guide the baby dragon through the village, the forest, the mountain pass, and the high peak, solving problems along the way (the bridge is out; the cave is too dark; the cliff needs a rope). The baby dragon has one ability: it can melt ice. This is sometimes the solution and sometimes the problem.

**ZIL fit:** Baby dragon as carried NPC object with special action; ice objects that transform when the dragon acts; multiple rooms with conditional exits.

---

### 4. The Snow Witch's Riddle
**Genre:** Winter Fairy Tale
**Tone:** Eerie and magical, Andersen / Grimm

Loosely inspired by Hans Christian Andersen's *The Snow Queen* (public domain). A winter spirit has frozen the village well, the miller's wheel, and the path home. She will unfreeze everything only if you answer her three riddles — one hidden in the frozen forest, one carved under the ice of the pond, one whispered by the talking wolf. Find the answers, return to her tower, and speak them.

**ZIL fit:** Three-object combination puzzle; NPC riddle interaction via TELL/ANSWER verbs; INVISIBLE objects revealed by solving earlier steps.

---

### 5. Space Cadet: First Mission
**Genre:** Sci-Fi / Humor
**Tone:** Slapstick, kid-friendly, space opera

Your first day at Space Cadet Academy and the training AI has gone haywire. It has locked the cafeteria, set the gravity controls to random, and announced that the graduation exam is "destroy the academy." Fix three systems (power junction, gravity control, the cafeteria door) before the Academy Inspector's shuttle docks. Each fix requires finding the right tool and using it in the right place.

**ZIL fit:** Three independent parallel puzzles; tool objects; clock countdown to inspector arrival; funny atmospheric events ("Gravity: 12%. Your lunch is on the ceiling.").

---

### 6. Detective Paws: The Missing Kittens
**Genre:** Mystery / Animals
**Tone:** Cozy, funny, kid detective

You are Detective Paws, the village's most capable dog. Five kittens have gone missing the night before the Great Animal Fair. Follow muddy paw-prints through the market, the bakery, the old barn, and the river bank. Each location has one clue object and one witness NPC. Collect all five clues, return to the barn, and deduce where the kittens are hiding (they got into the jam cellar chasing a smell and the door swung shut).

**ZIL fit:** Clue objects that build a picture; NPC witnesses with HELLO/TELL; final deduction as a SEARCH or OPEN action on a specific container.

---

### 7. The School Under the School
**Genre:** Magic / Discovery
**Tone:** Wonder-filled, slightly spooky, safe

A loose stone in the school basement leads to a hidden underground world — an old magical school that shut down centuries ago. You must find the three relics that will let you open the exit gate: a chalk wand, a bronze compass, and an ink bottle that writes the future. Each relic is protected by a simple puzzle left by the old students. Find all three, return to the gate, use them in order.

**ZIL fit:** Three-key combination lock; READBIT objects with lore; atmospheric clock events ("A bell rings somewhere below..."); INVISIBLE objects revealed by puzzle progress.

---

### 8. The Merfolk's Lost Pearl
**Genre:** Ocean Adventure
**Tone:** Adventurous, warm

Original story, no licensed characters. A merfolk elder asks you to find the Great Pearl that powers the undersea city's light. It was stolen by a giant crab who lives in the deep trench. You explore: the shallow reef, the kelp forest, the sunken ship, the dark trench. Each zone has an obstacle (a net blocking the path, a sleeping shark, a locked hatch on the ship) and a solution. Defeat the crab through cleverness (lure it with a shiny object, sneak past while it's distracted).

**ZIL fit:** Linear zone progression; NPC crab with GIVE/THROW interaction; timed "air bubble" clock event as pressure mechanic.

---

### 9. The Time Cupboard
**Genre:** Time Travel / History
**Tone:** Funny, educational

An old wardrobe in your grandmother's attic is a time machine. It's stuck cycling through three eras: ancient Egypt (a pyramid under construction), a Viking longship at sea, and a Victorian inventor's workshop. Each era has one broken thing you must fix using something borrowed from another era. Once all three are fixed, the wardrobe takes you home.

**ZIL fit:** Three mini-locations visited in sequence; objects carried between "worlds" (each world implemented as a room cluster); transformation puzzles.

---

### 10. The Fog at Elm Street
**Genre:** Light Mystery / Neighborhood Adventure
**Tone:** Gravity Falls-adjacent but original, no IP

A thick fog has rolled into your street. Your neighbors are acting strange — they keep walking in circles and can't remember their own names. You and your best friend discover the fog comes from a cracked old lantern buried in the park. Explore the neighborhood (five houses, the park, the old corner shop), gather the four items needed to repair the lantern (glass, copper wire, a wick, oil), and relight it to dispel the fog.

**ZIL fit:** Repair puzzle with four components; NPC neighbors who block paths but can be snapped out with a specific item; atmospheric clock events ("The fog thickens...").

---

## For Women — Detective & Romantic Interactive Novels

Stories for adult women who enjoy cozy mysteries, romantic suspense, and emotionally resonant choices. Inspired by Baroness Orczy (*The Scarlet Pimpernel*), Marie Belloc Lowndes (*The Terriford Mystery*), and the tradition of puzzle-box mysteries — all public domain in spirit. Three to five endings per story based on player choices.

---

### 11. A Death in Lavender Cove
**Genre:** Cozy Mystery / Slow-Burn Romance
**Tone:** Warm, witty, atmospheric

You inherit a secondhand bookshop in a sleepy coastal village and arrive to find the previous owner — your great-aunt — dead at the foot of the stairs. The local constable calls it an accident. The locals are less sure. As you unpack, brew too much tea, and introduce yourself to the village, you piece together a picture of a woman who knew too much about somebody. The infuriatingly methodical detective assigned to the case keeps appearing at inconvenient moments. You decide how much to trust him — and whether to confront the suspect yourself or hand him the evidence.

**ZIL fit:** 12 rooms across the village; clue objects in each; NPCs with TELL/GIVE interactions; relationship-tracking global flag (TRUST-DETECTIVE) that shapes the ending; two branching final scenes.

---

### 12. The Venetian Cipher
**Genre:** Romantic Thriller / Globetrotting Mystery
**Tone:** Glamorous, tense, sophisticated

Inspired by the Baroness Orczy tradition of high-society intrigue. You are an art authentication consultant attending a masked ball in Venice when a stolen manuscript — authenticated by your own signature six months ago — turns up in the wrong hands. A note pressed into your palm says *stop asking questions.* You must explore the palazzo, the canal docks, the archive, and the back rooms of an art dealer to find out who forged your signature, who is behind the theft, and whether the charming stranger helping you is ally or enemy.

**ZIL fit:** Investigation rooms with EXAMINE/SEARCH puzzles; a journal object that accumulates clues (READBIT, updated via PUTP); a trust/distrust NPC mechanic; three endings based on whether you expose the full conspiracy or take a safer route.

---

### 13. Second Chances in Bordeaux
**Genre:** Romantic Drama / Light Mystery
**Tone:** Reflective, bittersweet, emotionally layered

You take a solo trip to a friend's vineyard in the French countryside to clear your head after ending a long relationship. On arrival, you find the vineyard's elderly owner has just died and left the estate jointly to his two estranged adult children who haven't spoken in years. You are an unexpected witness to the will reading, a confidante to both siblings, and perhaps something more with one of them — if you choose. A question surfaces: was the old man's death truly natural? The deeper you look, the more tangled family history you uncover.

**ZIL fit:** 10 rooms across the vineyard estate; NPC siblings with separate conversation trees; a TRUST global that shifts based on who you confide in; optional mystery thread that can be pursued or left alone; four endings (leave early / stay as friend / stay as more / expose the secret).

---
