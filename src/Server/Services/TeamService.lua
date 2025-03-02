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

-- Variables
local RankService

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
end

-- Client Functions
--[[ 
    Handles the selection of a team by a player.
    Sets the player's team, rank, and role attributes, and assigns the player to the team.
    Fires an event to notify all clients about the team assignment.

    @function TeamSelected
    @param player Player -- The player who selected the team
    @param team string -- The name of the team selected by the player
    @within TeamService
]]
function TeamService.Client:TeamSelected(player : Player, team : string)
    local role = RankService:GetRole(player) or "Unknown"
    local rank = RankService:GetRank(player) or 0

    -- Set player attributes
    player:SetAttribute("Team", team)
    player:SetAttribute("Rank", rank)
    player:SetAttribute("Role", role)

    -- Assign player to the team if it exists
    if Teams:FindFirstChild(team) then
        player.Team = Teams[team]
    else
        warn("Invalid team selected: " .. team)
        return
    end

    -- Notify all clients about the team assignment
    self.AssignTeam:FireAll(player, team, rank, role)
end

-- Return Service to Knit
return TeamService
