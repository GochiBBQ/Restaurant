--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Service
local OrderService = Knit.CreateService {
    Name = "OrderService",
    Client = {},
}

-- Server Functions
function OrderService:KnitStart()
    
end

function OrderService:KnitInit()
    
end

 -- Return Service to Knit.
return OrderService
