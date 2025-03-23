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

-- Variables
local RankService
local playerTroveMap = {}

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

    -- Handle cleanup when players leave
    Players.PlayerRemoving:Connect(function(player)
        if playerTroveMap[player] then
            playerTroveMap[player]:Destroy()
            playerTroveMap[player] = nil
        end
    end)
end

-- Client Functions
function TeamService.Client:TeamSelected(player: Player, team: string)
    local role = RankService:GetRole(player) or "Unknown"
    local rank = RankService:GetRank(player) or 0

    -- Set player attributes
    player:SetAttribute("Team", team)
    player:SetAttribute("Rank", rank)
    player:SetAttribute("Role", role)

    -- Assign player to the team if it exists
    local teamObj = Teams:FindFirstChild(team)
    if teamObj then
        player.Team = teamObj
    else
        warn("Invalid team selected: " .. team)
        return
    end

    -- Setup or reset Trove per player
    if not playerTroveMap[player] then
        playerTroveMap[player] = Trove.new()
    else
        playerTroveMap[player]:Clean()
    end

    -- Fire signal to all clients
    self.AssignTeam:FireAll(player, team, rank, role)
end

-- Return Service to Knit
return TeamService
