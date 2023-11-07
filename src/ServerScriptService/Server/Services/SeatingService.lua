--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Sakura Kitchen 🥢
https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local SakuraAutomation = require(Knit.Modules.SakuraAutomation)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(5)

local FunctionalityFolder = workspace.Functionality
local TableFolder = FunctionalityFolder.TableManagement

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local SeatingService = Knit.CreateService {
    Name = "SeatingService",
	Client = {
		ToggleAFK = Knit.CreateSignal()	
	},
}

Knit.ClaimedTables = {} -- Knit.ClaimedTables[PlayerInstance] = Table of party members.

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function SeatingService:CreateTable(Server: Player, Customer: Player, Party: table, Table: number)
    for _, Tables in ipairs(TableFolder:GetDescendants()) do
        if Table:GetAttribute("TableNumber") == Table then
            Table:SetAttribute("TableClaimed", true)
            Table:SetAttribute("Customer", Customer)
            Table:SetAttribute("Server", Server)
        end
    end
    Knit.ClaimedTables[Table] = Party

    return true, string.format("Successfully reserved a table for %s", Customer.Name)
end

function SeatingService:RemoveTable(Customer: Player, Table: number)
    for _, Tables in ipairs(TableFolder:GetDescendants()) do
        if Table:GetAttribute("TableNumber") == Table then
            -- to do
        end
    end
end

function SeatingService:AddParty(Customer: Player, Target: Player)
    
end

function SeatingService:RemoveParty(Customer: Player, Target: Player)
    
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Client Functions
function SeatingService.Client:ReserveTable(Server: Player, Customer: Player, Party: table, Table: number)
    return self.Server:ReserveTable(Server, Customer, Party, Table)
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return SeatingService