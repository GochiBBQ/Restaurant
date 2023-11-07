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
local ServerStorage = game:GetService("ServerStorage")
local PlayerService = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local LiveEventService = Knit.CreateService {
	Name = "LiveEventService",
	Client = {
		Update = Knit.CreateSignal()	
	},
}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function LiveEventService:LaunchFirework(Firework: Instance)
    Firework.Fuse.Fire.Enabled = true
    Firework.LaunchSound:Play()
    Firework.Anchored = false
    task.wait(math.random(1.5, 2.5))

    -- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
    -- Wait a second to launch the firework.
    Firework.Fuse.Fire:Destroy()
    Firework.ExplodeSound:Play()
    Firework.Transparency = 1

    -- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
    -- Create the firework explosion effect.
    for _, v in pairs(Firework.Explosion:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(80)
		end
	end

    -- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
    -- Wait a second to destroy the firework.
    task.wait(1)
    Firework:Destroy()
end

function LiveEventService:FireworkShow()
    for repeatCount = 1, 4 do
        for _, Fireworks in pairs(ServerStorage.Fireworks:GetChildren()) do
            local ClonedFirework = Fireworks:Clone()
            ClonedFirework.Parent = workspace

            -- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
            -- Delay the launch for a second.
            task.delay(1, function()
                self:LaunchFirework(ClonedFirework)
            end)
        end
        task.wait(3)
    end

    -- camera shake n stuff after just testing lolz
end

task.delay(5, function()
    LiveEventService:FireworkShow()
end)


-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return LiveEventService