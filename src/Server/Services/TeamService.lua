--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TableMap = require(ServerScriptService.Structures.TableMap) --- @module TableMap

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

    -- Count players in each team
    local chefTeam = Teams:FindFirstChild("Chef")
    local serverTeam = Teams:FindFirstChild("Server")
    local chefCount = chefTeam and #chefTeam:GetPlayers() or 0
    local serverCount = serverTeam and #serverTeam:GetPlayers() or 0

    -- Enforce ratio after both teams have at least one player
    if chefCount == 0 or serverCount == 0 then
        -- Allow players to join either team until both have at least one member
        print("One team is still empty. Allowing team join without ratio enforcement.")
    else
        -- Enforce 2 servers to 1 chef ratio
        if team == "Server" and serverCount >= chefCount * 2 then
            warn("Cannot assign player to Server team. Ratio exceeded.")
            return false, "Server team is full."
        elseif team == "Chef" and chefCount >= math.floor(serverCount / 2) then
            warn("Cannot assign player to Chef team. Ratio exceeded.")
            return false, "Chef team is full."
        end
    end


    -- Set player attributes
    player:SetAttribute("Team", team)
    player:SetAttribute("Rank", rank)
    player:SetAttribute("Role", role)

    -- Assign player to the team
    local teamObj = Teams:FindFirstChild(team)
    if teamObj then
        player.Team = teamObj
    else
        warn("Invalid team selected: " .. team)
        return
    end

    -- Manage Trove for cleanup
    local trove = playerTroveMap:get(player)
    if not trove then
        trove = Trove.new()
        playerTroveMap:set(player, trove)
    else
        trove:Clean()
    end

    -- Notify clients
    self.AssignTeam:FireAll(player, team, rank, role)
end

-- Return Service to Knit
return TeamService
