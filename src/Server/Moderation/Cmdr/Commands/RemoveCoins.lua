return {
    Name = "removecoins",
    Description = "Remove coins from a player.",
    Group = "Coins",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to remove coins from.",
        },
        {
            Type = "number",
            Name = "coins",
            Description = "The amount of coins to rermove from the player.",
        }
    },
}