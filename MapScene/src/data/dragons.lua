local dragons = {
    order = { "kaela", "veyra", "sarka", "nyxara", "aurelia" },
}

dragons.kaela = {
    name = "Kaela",
    title = "The Smith",
    place = "Forge",
    passive = "kaela_challenge_chain",
    accent = { 0.96, 0.31, 0.12 },
    text = "Direct, competitive, and convinced the forge is a gym if you use it right.",
    moodWeights = {
        competitive = 35,
        curious = 15,
        vulnerable = 10,
        playful = 25,
        relaxed = 15,
    },
    quotes = {
        competitive = "Sure you can handle another set?",
        curious = "Good. Explain the clever part.",
        vulnerable = "Do not make a big thing out of this.",
        playful = "That swing had style. Maybe too much.",
        relaxed = "The forge is quiet for once.",
    },
    ending = "Kaela waits for you at the festival with a grin and two slightly scorched tickets.",
}

dragons.veyra = {
    name = "Veyra",
    title = "The Knight",
    place = "Training Yard",
    passive = "veyra_first_each_type",
    accent = { 0.18, 0.74, 0.95 },
    text = "Disciplined, precise, and secretly ready to be surprised.",
    moodWeights = {
        competitive = 20,
        curious = 30,
        vulnerable = 15,
        playful = 10,
        relaxed = 25,
    },
    quotes = {
        competitive = "A clear answer, please.",
        curious = "That angle is interesting.",
        vulnerable = "Improvising is not my specialty.",
        playful = "This is irregular. Continue.",
        relaxed = "I can allow exactly one quiet minute.",
    },
    ending = "Veyra arrives exactly on time, then admits she came early out of nerves.",
}

dragons.sarka = {
    name = "Sarka",
    title = "The Brawler",
    place = "Arena",
    passive = "sarka_pressure_bonus",
    accent = { 0.44, 0.86, 0.18 },
    text = "Loud, warm, impulsive, and happiest when everything is on the edge.",
    moodWeights = {
        competitive = 30,
        curious = 15,
        vulnerable = 5,
        playful = 40,
        relaxed = 10,
    },
    quotes = {
        competitive = "Loser buys snacks.",
        curious = "Wait, that might work.",
        vulnerable = "Do not tell anyone I got thoughtful.",
        playful = "Now we are talking!",
        relaxed = "Even champions sit down sometimes.",
    },
    ending = "Sarka turns the festival invitation into a bet, then refuses to lose it.",
}

dragons.nyxara = {
    name = "Nyxara",
    title = "The Arcanist",
    place = "Archive",
    passive = "nyxara_insight",
    accent = { 0.69, 0.35, 0.94 },
    text = "Quiet, observant, and funnier than her notes suggest.",
    moodWeights = {
        competitive = 10,
        curious = 40,
        vulnerable = 20,
        playful = 15,
        relaxed = 15,
    },
    quotes = {
        competitive = "A hypothesis with teeth. Good.",
        curious = "Tell me how you got there.",
        vulnerable = "I am listening. Slowly, but fully.",
        playful = "That joke has an alarming structure.",
        relaxed = "Silence also informs.",
    },
    ending = "Nyxara brings a festival route annotated with stars and one shy heart.",
}

dragons.aurelia = {
    name = "Aurelia",
    title = "The Guardian",
    place = "Gate",
    passive = "aurelia_pressure_control",
    accent = { 0.94, 0.78, 0.28 },
    text = "Protective, patient, and unused to anyone looking after her.",
    moodWeights = {
        competitive = 10,
        curious = 20,
        vulnerable = 30,
        playful = 5,
        relaxed = 35,
    },
    quotes = {
        competitive = "Careful. Strength should still be kind.",
        curious = "That is worth considering.",
        vulnerable = "You noticed more than most.",
        playful = "A little audacity suits you.",
        relaxed = "There is no need to rush.",
    },
    ending = "Aurelia accepts the invitation softly, as if trusting joy takes practice.",
}

return dragons
