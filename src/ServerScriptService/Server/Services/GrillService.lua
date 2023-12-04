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
local trove = Trove.new()

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local GrillService = Knit.CreateService {
    Name = "GrillService",
	Client = {
	},
}

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function GrillService:KnitStart()
	for i, v in pairs(workspace:WaitForChild("Tables"):GetChildren()) do
		if v:IsA("Model") then
			self.ActiveGrills[v.Name] = 5
			self.PlayerUsing[v.Name] = ""

			v.TableGrill.GrillBottom.ProximityPrompt.Triggered:Connect(function(Player)
				if self.ActiveGrills[v.Name] > 0 then
					self:SetActiveUser(Player, v.Name)
				end
			end)
		end
	end
end

function GrillService:SetActiveUser(Player: Player, Grill: string)
	if not Player or not Grill then
		return
	end

	self.ActiveGrills[Grill] -= 1
	self.PlayerUsing[Grill] = Player
end

function GrillService:DisplayItem(Grill: string, Item: string, Value: boolean)
	if not Value then
		Value = false
	end

	if not workspace.Tables[Grill] then
		return
	end

	if Value and workspace.Tables[Grill].TableGrill.Food:FindFirstChild(Item) then
		workspace.Tables[Grill].TableGrill.Food:FindFirstChild(Item).Transparency = 0
	else
		workspace.Tables[Grill].TableGrill.Food:FindFirstChild(Item).Transparency = 1
	end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return GrillService