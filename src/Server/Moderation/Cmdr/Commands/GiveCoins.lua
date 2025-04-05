return {
    Name = "givecoins",
    Description = "Give a player coins.",
    Group = "Coins",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to give coins to.",
        },
        {
            Type = "number",
            Name = "coins",
            Description = "The amount of coins to give the player.",
        }
    },
}