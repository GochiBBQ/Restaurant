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
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new() -- USE TROVE TO DISCONNECT REMOTE CONNECTIONS (ONLY DISCONNECT IF ITS ONLY USED ONCE) (DONT USE ON PLAYERADDED N STUFF)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4) -- USE TO CREATE A RATE LIMIT RequestRateLimiter:CheckRate() can be used to check rate limit (true means no rate limit)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local TemplateService = Knit.CreateService {
    Name = "TemplateService",
	Client = {
        TemplateRemote = Knit:CreateSignal()
	},
}

Knit.TemplateVariable = nil

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function TemplateService:KnitInit()
    
end

function TemplateService:KnitStart()

end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return TemplateService