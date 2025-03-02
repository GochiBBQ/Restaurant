--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

local Table = require(Knit.Classes.Table) --- @module Table
local Grill = require(Knit.Classes.Grill) --- @module Grill

-- Create Knit Service
local CookingService = Knit.CreateService {
    Name = "CookingService",
    Client = {},
}

-- Server Functions
function CookingService:KnitStart()
    
end

function CookingService:KnitInit()
    
end

 -- Return Service to Knit.
return CookingService
