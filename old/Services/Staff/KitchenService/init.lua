--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- ————————— 🂡 —————————
-- Create Knit Service
local KitchenService = Knit.CreateService {
    Name = "KitchenService",
    Client = {
        --Chef Queue
        Enqueue = Knit.CreateSignal(),
        Dequeue = Knit.CreateSignal(),
        Update = Knit.CreateSignal()

        -- Cooking System
    },
}

-- ————————— 🂡 —————————
-- Server Functions
function KitchenService:KnitStart()
    
end

function KitchenService:KnitInit()
    
end

-- ————————— 🂡 —————————
 -- Return Service to Knit.
return KitchenService
