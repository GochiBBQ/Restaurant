return {
    Name = "removexp",
    Description = "Remove xp from a player.",
    Group = "XP",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to remove xp from.",
        },
        {
            Type = "number",
            Name = "xp",
            Description = "The amount of xp to rermove from the player.",
        }
    },
}