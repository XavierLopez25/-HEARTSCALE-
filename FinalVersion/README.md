# Heartscale: Final Version

Final delivery. It builds on the complete game (progression, card packs, collection, dates, weekly recap and the Festival ending), the explorable map of the Iron Scale Guild from `MapScene/`, and the final dragon portraits.

```
Title → Progression → Pack → Collection → Map → Date → Recap → (next week) … → Festival ending
```

---

## 1. What is new compared to MapScene

| Area | Before (MapScene) | Now (FinalVersion) |
| --- | --- | --- |
| Dragon portraits | Primitive mock shapes in the dragon's color | Final pixel-art busts (128 x 128) for Kaela, Veyra, Sarka, Nyxara and Aurelia |
| Where they appear | Date screen and Festival result | Same screens, now with the real art |
| Portrait card | Name and title overlapped | Name and title spaced; the bust rests on the name area |

- **Source art:** each portrait comes from a `.ase` file in the root `dragons/` folder. The game uses only the visible layer; the hidden layer is a reference background. The PNGs live in [`assets/dragons/`](assets/dragons/), named after the dragon ids (`kaela.png`, `veyra.png`, …).
- **Hand-drawn final designs:** Kaela comes from `dragons/Kaela.ase`. Veyra, Sarka, Nyxara and Aurelia are hand-drawn redesigns in Kaela's style, from `dragons/<Name>_styled.ase`. Each PNG is exactly the visible layer of its `.ase`, exported without changes.
- **Data-driven:** each dragon in [`src/data/dragons.lua`](src/data/dragons.lua) has a `portrait` path.
- **Loader:** [`src/ui/DragonPortraits.lua`](src/ui/DragonPortraits.lua) loads each image once, checks it is exactly 128 x 128, and uses nearest-neighbor filtering.
- **Safe fallback:** if a portrait is missing or has the wrong size, the console prints a `[portraits]` warning and `Draw.portrait` draws the old mock instead. Missing art never crashes the game.
- **Integer scaling only:** portraits are drawn at 1x on the 640 x 400 canvas, so they stay crisp at any window scale.

## 2. The map (from MapScene)

The map is the campus of the **Iron Scale Guild**. Each week, after the collection, the protagonist leaves the Guild Hall and chooses whom to visit by walking to her place:

| Location | Dragon |
| --- | --- |
| Forge | Kaela |
| Training Yard | Veyra |
| Arena | Sarka |
| Archive | Nyxara |
| Gate | Aurelia |
| Guild Hall | Back to Collection |

- [`src/data/map.lua`](src/data/map.lua) is the single source of truth for the geometry.
- `MapScene` follows **Setup → Update → Render**:
  - `MapSetupSystem` creates the entities.
  - `MapMovementSystem`, `MapCollisionSystem` and `MapInteractionSystem` handle the update.
  - `MapRenderSystem` draws the scene.
- Movement runs at 95 px/s with normalized diagonals. Collisions are AABB, resolved per axis with sub-steps, and the player is clamped to the map bounds.
- The pixel art in [`assets/map/`](assets/map/) is optional, with primitive placeholders as fallback.

## 3. Controls

| Key | Action |
| --- | --- |
| Arrows / WASD | Move on the map; navigate menus elsewhere |
| Enter / Space | Visit the nearby location; confirm elsewhere |
| Backspace | Map → Collection |
| M | Take a Breath once per date (+1 Pressure) |
| Esc | Quit |
| F1 | Debug overlay |
| F2 + 1-8 | Scene jump: 1 title, 2 progression, 3 pack, 4 collection, 5 map, 6 date, 7 recap, 8 ending |
| F3 / F4 / F5 | Debug +1 Valor / Wit / Empathy |
| F6 | Debug +1 affection for the current dragon |
| F7 / F8 | Debug +1 Chemistry / Pressure during dates |

## 4. Running

Requires LÖVE 11.5.

```sh
cd FinalVersion
love .
```

## 5. Tests

Run from inside `FinalVersion/` with Lua 5.4. No window is needed.

```sh
lua tests/generation.lua
lua tests/date_resolution.lua
lua tests/date_dialogue.lua
lua tests/flow.lua
lua tests/balance.lua
lua tests/map.lua
lua tests/portraits.lua
```

### Text fit audit

Every string the game can show is checked against its box with the game's real fonts and layouts:

```sh
cd FinalVersion
love tools/text_audit
```

The audit covers:

- cards and card details in every size used by the game;
- the date mood panel for every dragon and mood;
- the date feedback for every dragon, mood, card and resolver state, including risky successes and failures;
- recap, ending, progression, map prompts and signs, and the title.

It reports overflow, overlapping blocks and words split across lines, and exits with code 1 if anything fails. Card faces, card details and the mood panel lay out each block by the real height of its wrapped text, so content can grow without overlapping.

`tests/portraits.lua` checks that:

- every dragon has a unique portrait path;
- each file exists and is a 128 x 128 RGBA PNG (read from the PNG header);
- the loader returns nothing when running headless, so the mock fallback is used.
