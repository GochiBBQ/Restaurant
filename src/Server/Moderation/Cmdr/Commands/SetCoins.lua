return {
    Name = "setcoins",
    Description = "Set a player's coins.",
    Group = "Coins",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to set coins for.",
        },
        {
            Type = "number",
            Name = "coins",
            Description = "The amount of coins to set for the player.",
        }
    },
}