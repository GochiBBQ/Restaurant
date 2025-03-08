return {
    Name = "setxp",
    Description = "Set a player's xp.",
    Group = "XP",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to set xp for.",
        },
        {
            Type = "number",
            Name = "xp",
            Description = "The amount of xp to set for the player.",
        }
    },
}