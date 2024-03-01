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

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(25)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local AFKService = Knit.CreateService {
    Name = "AFKService",
	Client = {
		ToggleAFK = Knit.CreateSignal()	
	},
}

-- ————————— ↢ ⭐️ ↣ —————————
-- Server Functions
function AFKService:MarkAFK(Player: Player, Status: boolean)
	if Player and (Status == true or Status == false) then
		local IsAFK = Player:GetAttribute("AFK")
		local Character= Player.Character

		if not IsAFK and Status then
			Player:SetAttribute("AFK", Status)

			task.spawn(function()
				for i,v in pairs(Player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Material = "ForceField"
					end
				end
			end)
		elseif not Status then
			Player:SetAttribute("AFK", Status)

			task.spawn(function()
				for i,v in pairs(Player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Material = "Plastic"
					end
				end
			end)
		end
	end
end

function AFKService:KnitInit()
	self.Client.ToggleAFK:Connect(function(Player, Status)
		if RequestRateLimiter:CheckRate(Player) then
			self:MarkAFK(Player, Status)
		end
	end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return AFKService