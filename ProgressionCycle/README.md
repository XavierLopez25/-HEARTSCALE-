# Heartscale - Progression Cycle

Second delivery built after `UISystems/`. It keeps the same early UI base and adds the connected progression cycle:

- Progression screen: choose training activities that modify shared stats and weekly tags.
- Card acquisition screen: generate a weekly offer influenced by the current stats.
- Collection screen: persist acquired cards and inspect their data after scene changes.

The card rule is weighted: each card type receives weight `stat + 1`, so higher Valor produces more Challenge cards, higher Wit produces more Wit cards, and higher Empathy produces more Connection cards.

Delivery notes:

- This version is sequentially built from `UISystems/`.
- The previous UI systems remain available through the main menu's `UI Preview` option.
- Shared state persists week, actions, stats, weekly tags, selected dragon, affection, and card collection.
- Logic is split across input, gameplay/update, generation, navigation, and render systems.

Run with:

```sh
love .
```

Test with:

```sh
lua tests/progression_cycle.lua
lua tests/regressions.lua
```
