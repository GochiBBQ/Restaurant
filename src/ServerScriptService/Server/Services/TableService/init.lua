--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local GrillService = Knit.CreateService {
    Name = "GrillService";
    Client = {};
    ActiveGrills = {};
}

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function GrillService:KnitStart()
    local TableGrill = require(script.TableGrills)

    for _, Table in ipairs(workspace.Functionality.TableGrills:GetChildren()) do
        local tableGrill = TableGrill.new(Table)
        self.ActiveGrills[Table.Name] = tableGrill
    end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return GrillService