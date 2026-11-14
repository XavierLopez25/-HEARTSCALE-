# Heartscale: Map Scene

Third delivery with one major addition: an **explorable map scene** of the Iron Scale Guild. The map replaces the old weekly Dragon Select menu XD


Before:  Title → Progression → Pack → Collection → Dragon Select → Date → Recap → ...
Now:     Title → Progression → Pack → Collection → Map → Date → Recap → ...

---

## 1. What the map represents

The map is the campus of the **Iron Scale Guild**, where the protagonist trains and meets the five dragons. Each week, after reviewing the collection, the player walks out of the Guild Hall and chooses whom to visit by walking to her place in the guild.


## 2. Layout and points of interest

All geometry lives in a single source of truth: [`src/data/map.lua`](src/data/map.lua). It holds the dimensions, bounds, spawn, walls, terrain, buildings, doors, interaction zones and obstacles.

- Every building is solid. Its **interaction zone** sits in front of its door, outside every collider. A test verifies this.
- Roads and the central courtyard connect all doors. A flood-fill test from the spawn proves that every interaction zone is reachable.
- Placeholder readability: each location uses its dragon's accent color for roof, outline and door frame. Each has a sign with an icon (the dragon's initial), the place name and the dragon's name. A small colored doormat marks every interaction zone. The nearby zone and its building are highlighted.


## 3. Setup → Update → Render

`MapScene` ([`src/scenes/MapScene.lua`](src/scenes/MapScene.lua)) uses the same `Scene` / `Registry` ECS as the rest of the game. `Scene:setup()`, `Scene:update(dt)` and `Scene:draw()` run each system's `setup`, `update` and `draw` functions in the order the systems were registered.

| Phase | System | Responsibility |
| --- | --- | --- |
| **Setup** | [`MapSetupSystem`](src/systems/MapSetupSystem.lua) | Reads `map.lua` and spawns entities: terrain, walls, buildings with `pointOfInterest`, obstacles and the player. It creates the `mapState` resource, injects `runState` and loads optional art. It runs on every scene entry, so each week starts in front of the Guild Hall. |
| **Update** 1 | [`MapMovementSystem`](src/systems/MapMovementSystem.lua) | Reads held keys (arrows/WASD), normalizes the direction vector and writes `velocity = direction * 95 px/s`. It also updates facing and walk-animation time. |
| **Update** 2 | [`MapCollisionSystem`](src/systems/MapCollisionSystem.lua) | Integrates `velocity * dt` and resolves AABB collisions **per axis** (X, then Y) against all solid colliders. It then clamps the player to the map bounds. |
| **Update** 3 | [`MapInteractionSystem`](src/systems/MapInteractionSystem.lua) | Finds the POI whose interaction zone overlaps the player, builds the prompt and handles Enter/Space (visit) and Backspace (return). |
| **Render** | [`MapRenderSystem`](src/systems/MapRenderSystem.lua) | Draws, in order: grass grid, roads and courtyard, wall, interaction markers, props, buildings and signs, player, header and footer prompt. It uses LibreSprite atlases if present and placeholders otherwise. |

## 4. Movement

- Movement is continuous while a key is held: arrow keys or WASD.
- Speed is **95 px/s** (`map.player.speed`) and is scaled by `dt`, so it does not depend on frame rate.
- **Diagonals are normalized:** the direction vector is divided by its length, so up+right moves at 95 px/s, not 134 px/s.
- Opposite keys cancel out. Facing follows the last axis pressed, for the future 4-direction sprite.
- The player placeholder is a 12 x 16 rectangle with hair and a facing dot. With art, it becomes a 16 x 24 sprite anchored to the same collider.

## 5. Bounds

`map.bounds = { x = 16, y = 16, w = 608, h = 320 }` is the walkable area inside the perimeter wall. After every collision step the player is clamped to it. The perimeter wall is also a set of solid colliders, so the bounds are enforced twice.

## 6. Collisions

- Plain AABB, with no physics library.
- **Separate axes:** move on X, push out of any overlapping solid in the opposite direction of travel, then do the same on Y. This lets the player slide along walls when moving diagonally.
- **No tunneling:** each frame's displacement is split into sub-steps of at most 4 px, which is smaller than the thinnest obstacle (8 px fences). Even a 5-second frame cannot cross a wall.
- Solids are the perimeter walls, the six buildings, and props: well, crates, barrels, benches, fences, trees and the weapon rack.

## 7. Interactions and transitions

| Situation | Result |
| --- | --- |
| Standing in front of a dragon's door | Footer shows e.g. `Enter: Visit Kaela at the Forge` in her color |
| Enter / Space in front of a dragon's door | `RunState.currentDragon = dragonId` → `confirm` sound → switch to `date` |
| Enter / Space in front of the Guild Hall | `confirm` sound → back to `collection` |
| Enter / Space anywhere else | Nothing happens |
| Backspace anywhere on the map | Back to `collection` without choosing a dragon |
| Collection, Enter | Switches to `map` (footer: `Enter: continue to the guild map`) |

The player's position is not persisted. Every entry into the map starts at the Guild Hall spawn XD

## 8. Controls (updated)

| Key | Action |
| --- | --- |
| Arrows / WASD | Move on the map; navigate menus elsewhere |
| Enter / Space | Visit the nearby location; confirm elsewhere |
| Backspace | Map → Collection |
| M | Take a Breath once per date (+1 Pressure) |
| Esc | Quit |
| F1 | Debug overlay (on the map it also shows player X/Y and the nearby POI) |
| F2 + 1-8 | Scene jump: 1 title, 2 progression, 3 pack, 4 collection, **5 map**, 6 date, 7 recap, 8 ending |
| F3 / F4 / F5 | Debug +1 Valor / Wit / Empathy |
| F6 | Debug +1 affection for the current dragon |
| F7 / F8 | Debug +1 Chemistry / Pressure during dates |
