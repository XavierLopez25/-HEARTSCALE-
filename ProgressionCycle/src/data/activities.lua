return {
    order = { "forge_training", "tactical_study", "guild_help" },
    forge_training = {
        name = "Forge Training",
        short = "Train",
        effects = { valor = 2 },
        tags = { "training", "challenge" },
        relatedType = "challenge",
        lines = {
            "Kaela turns hammer work into a brutal set of reps.",
            "You learn where force ends and posture begins.",
            "The forge leaves your arms shaking, but your stance holds.",
        },
    },
    tactical_study = {
        name = "Tactical Study",
        short = "Study",
        effects = { wit = 2 },
        tags = { "study", "strategy" },
        relatedType = "wit",
        lines = {
            "An old map reveals three useful mistakes.",
            "You spot the pattern behind a training drill.",
            "Nyxara's notes turn a confusing diagram into a plan.",
        },
    },
    guild_help = {
        name = "Guild Help",
        short = "Help",
        effects = { empathy = 2 },
        tags = { "support", "care" },
        relatedType = "connection",
        lines = {
            "You ask before helping, and Aurelia notices.",
            "You carry supplies and listen better than you speak.",
            "A quiet kindness changes the room more than a speech.",
        },
    },
}
