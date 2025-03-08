return {
    Name = "givexp",
    Description = "Give a player xp.",
    Group = "XP",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to give xp to.",
        },
        {
            Type = "number",
            Name = "xp",
            Description = "The amount of xp to give the player.",
        }
    },
}