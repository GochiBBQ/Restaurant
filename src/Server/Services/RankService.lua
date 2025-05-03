--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService: HttpService = game:GetService('HttpService')
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Signal: ModuleScript = require(ReplicatedStorage.Packages.Signal)
local TableMap: ModuleScript = require(ServerScriptService.Structures.TableMap) --- @module TableMap

-- Create Knit Service
local RankService = Knit.CreateService {
    Name = "RankService",
    Client = {
        Update = Knit.CreateSignal()
    },
    PlayerTable = TableMap.new(), -- UserId → { Rank, Role }
    UpdateRank = Signal.new()
}

-- Variables
local url: string = "http://138.197.80.59:3001"
local key: string = "QJvdks3RUn6vklV1G2kQPsUsclZxvDzd"

-- Server Functions
function RankService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        self.PlayerTable:set(Player.UserId, {
            Rank = Player:GetRankInGroup(5874921),
            Role = Player:GetRoleInGroup(5874921),
        })
    end)

    Players.PlayerRemoving:Connect(function(Player)
        self.PlayerTable:remove(Player.UserId)
    end)
end

function RankService:GetRank(Player)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local data = self.PlayerTable:get(Player.UserId)
    return (data and data.Rank) or Player:GetRankInGroup(5874921)
end

function RankService:GetRole(Player)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local data = self.PlayerTable:get(Player.UserId)
    return data and data.Role or Player:GetRoleInGroup(5874921)
end

function RankService:Update(Player)
    task.delay(5, function()
        self.PlayerTable:set(Player.UserId, {
            Rank = Player:GetRankInGroup(5874921),
            Role = Player:GetRoleInGroup(5874921),
        })

        self.Client.Update:Fire(Player, self:GetRank(Player), self:GetRole(Player))
        self.UpdateRank:Fire(Player)
    end)
end

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

-- Client Functions
function RankService.Client:Get(Player)
    return self.Server:GetRank(Player), self.Server:GetRole(Player)
end

function RankService.Client:Set(Player, Rank)
    return self.Server:SetRank(Player, Rank)
end

-- Return Service to Knit.
return RankService
