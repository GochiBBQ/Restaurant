--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TableMap = require(Knit.Structures.TableMap) --- @module TableMap

-- Variables
local RankService
local playerTroveMap = TableMap.new() -- Player → Trove

-- Create Knit Service
local TeamService = Knit.CreateService {
    Name = "TeamService",
    Client = {
        AssignTeam = Knit.CreateSignal(),
        PlayerJoined = Knit.CreateSignal(),
    },
}

-- Server Functions
function TeamService:KnitStart()
    RankService = Knit.GetService("RankService")

    Players.PlayerRemoving:Connect(function(player)
        local trove = playerTroveMap:get(player)
        if trove then
            trove:Destroy()
            playerTroveMap:remove(player)
        end
    end)
end

-- Client Functions
function TeamService.Client:TeamSelected(player: Player, team: string)
    local role = RankService:GetRole(player) or "Unknown"
    local rank = RankService:GetRank(player) or 0

    player:SetAttribute("Team", team)
    player:SetAttribute("Rank", rank)
    player:SetAttribute("Role", role)

    local teamObj = Teams:FindFirstChild(team)
    if teamObj then
        player.Team = teamObj
    else
        warn("Invalid team selected: " .. team)
        return
    end

    local trove = playerTroveMap:get(player)
    if not trove then
        trove = Trove.new()
        playerTroveMap:set(player, trove)
    else
        trove:Clean()
    end

    self.AssignTeam:FireAll(player, team, rank, role)
end

-- Return Service to Knit
return TeamService
