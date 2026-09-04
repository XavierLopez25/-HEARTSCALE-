# Heartscale - UI Systems

Implemented UI systems:

- `MainMenuUISystem`: setup creates menu buttons, update handles navigation/activation, draw renders the title UI.
- `CharacterSelectUISystem`: setup reads the selected dragon from shared state, update changes the selected dragon, draw renders portraits and details.
- `DialogueUISystem`: setup creates dialogue choices, update applies the selected response to affection, draw renders dialogue and response UI.

Notes:

- Breakout code/resources are not present in this version.
- Each UI system is integrated with game state or scene flow.
- The dragon portraits are placeholder sprites drawn with LÖVE shapes instead of plain rectangles.


Run with:

```sh
love .
```
