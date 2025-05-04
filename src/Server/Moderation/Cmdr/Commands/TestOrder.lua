return {
    Name = "testorder",
    Description = "Submits a fake order for a player and completes it for testing.",
    Group = "Orders",
    Args = {
        {
            Type = "players",
            Name = "player",
            Description = "The player to simulate the order for.",
        },
        {
            Type = "string",
            Name = "item",
            Description = "The item to test (must exist in order system).",
        }
    }
}