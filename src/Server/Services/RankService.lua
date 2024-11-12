--[[

Author: alreadyfans
For: Gochi

]]

-- ————————— 🂡 —————————

-- Services
local HttpService = game:GetService('HttpService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- ————————— 🂡 —————————
-- Create Knit Service
local RankService = Knit.CreateService {
    Name = "RankService",
    Client = {
        Update = Knit.CreateSignal()
    },
    PlayerTable = {},
    UpdateRank = Signal.new()
}

-- ————————— 🂡 —————————
-- Variables
local url = "http://138.197.80.59:3001"
local key = "QJvdks3RUn6vklV1G2kQPsUsclZxvDzd"

-- ————————— 🂡 —————————
-- Server Functions

--[[ 
    Initializes the RankService by setting up event listeners for player addition and removal.
    When a player is added, their rank and role in the group with ID 5874921 are stored in the PlayerTable.
    When a player is removed, their entry is removed from the PlayerTable.

    @function KnitStart
    @within RankService
]]
function RankService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        self.PlayerTable[Player.UserId] = {Rank = Player:GetRankInGroup(5874921), Role = Player:GetRoleInGroup(5874921)}
    end)

    Players.PlayerRemoving:Connect(function(Player)
        self.PlayerTable[Player.UserId] = nil
    end)
end

--[[ 
    Retrieves the rank of a player from the PlayerTable.
    Waits until the player's "Loaded" attribute is true before checking the PlayerTable.
    If the player exists in the PlayerTable, returns their rank.
    Otherwise, returns 0.

    @function GetRank
    @param Player The player whose rank is to be retrieved.
    @return number The rank of the player, or 0 if the player is not found in the PlayerTable.
    @within RankService
]]
function RankService:GetRank(Player)
    repeat task.wait() until Player:GetAttribute("Loaded")

    if self.PlayerTable[Player.UserId] then
        return self.PlayerTable[Player.UserId].Rank
    else
        return 0
    end
end

--[[ 
    Retrieves the role of a player from the PlayerTable.
    Waits until the player's "Loaded" attribute is true before proceeding.
    If the player's UserId exists in the PlayerTable, returns the player's role.
    Otherwise, returns an empty string.

    @function GetRole
    @param Player The player whose role is to be retrieved.
    @return string The role of the player or an empty string if the player is not found.
    @within RankService
]]
function RankService:GetRole(Player)
    repeat task.wait() until Player:GetAttribute("Loaded")

    if self.PlayerTable[Player.UserId] then
        return self.PlayerTable[Player.UserId].Role
    else
        return ""
    end
end

--[[ 
    Updates the rank and role of a player in the PlayerTable after a delay of 5 seconds.
    Fires client and server events to update the player's rank and role.

    @function Update
    @param Player The player whose rank and role are to be updated.
    @within RankService
]]
function RankService:Update(Player)
    task.delay(5, function()
        self.PlayerTable[Player.UserId] = {Rank = Player:GetRankInGroup(5874921), Role = Player:GetRoleInGroup(5874921)}
        self.Client.Update:Fire(Player, self:GetRank(Player), self:GetRole(Player))
        self.UpdateRank:Fire(Player)
    end)
end

--[[ 
    Sets the rank of a player by making an HTTP POST request to a specified URL.
    The function sends the player's user ID and the desired rank in the request body.
    If the request is successful, it updates the player's rank locally.
    If the request fails, it logs a warning message.

    @function SetRank
    @param Player Player -- The player whose rank is to be set.
    @param Rank number -- The rank to be assigned to the player.
    @return boolean -- Returns true if the rank was successfully set, false otherwise.
    @within RankService
]]
function RankService:SetRank(Player, Rank)
    local success, response = pcall(HttpService.RequestAsync, HttpService, {
        Url = ("%s/setrank"):format(url),
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = key,
        },
        Body = HttpService:JSONEncode({
            id = Player.UserId,
            role = Rank,
        }),
    })

    if success then
        response = HttpService:JSONDecode(response.Body)
        if response.success then
            self:Update(Player)
            return true
        else
            warn(("Error with %d: %s"):format(Player.UserId, response.msg))
        end
    else
        warn("HTTP request failed")
    end

    return false
end

-- ————————— 🂡 —————————
-- Client Functions

function RankService.Client:Get(Player)
    return self.Server:GetRank(Player), self.Server:GetRole(Player)
end

function RankService.Client:Set(Player, Rank)
    return self.Server:SetRank(Player, Rank)
end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return RankService
