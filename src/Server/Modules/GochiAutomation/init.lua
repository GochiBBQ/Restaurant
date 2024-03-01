-- ————————— 🂡 —————————
-- Services
local HttpService = game:GetService("HttpService")
local Http = require(script.HttpQueue)

-- ————————— 🂡 —————————
-- Variables
local URL = "http://159.203.176.24" -- http://159.203.176.24
local secureKey = "ADD SECURE KEY HERE"
local SakuraModule = {}

-- ————————— 🂡 —————————
-- Activity Tracking

-- ————————— 🂡 —————————
-- Leaderstats
function SakuraModule.GetLevel(Player: Player)
	
end

function SakuraModule.UpdateLevel(Player: Player, Level: number)
	
end

function SakuraModule.GetXP(Player: Player)
	
end

function SakuraModule.UpdateXP(Player: Player, XP: number)
	
end

function SakuraModule.GetPetals(Player: Player)
	
end

function SakuraModule.UpdatePetals(Player: Player, Petals: number)
	
end

-- ————————— 🂡 —————————
-- Blacklist Tracking
function SakuraModule:CheckBlacklist(Player: Player)
	-- return wether they r lr or mr blacklisted or both
end

function SakuraModule:Blacklist(Player: Player, Reason: string)
	-- return wether they r lr or mr blacklisted or both
end

-- ————————— 🂡 —————————
-- Discord Tracking
function SakuraModule:CheckBooster(Player: Player)
	local response, data = pcall(function()
		return HttpService:GetAsync(URL..'/v1/role-status/'..Player.UserId)
	end)

	if response then
		data = HttpService:JSONDecode(data)
		
		if data.data then
			local roles = data.data
			if table.find(roles, 'Booster') then
				return true
			end
		end
	end
end

function SakuraModule:CheckAlliance(Player: Player)
	local response, data = pcall(function()
		return HttpService:GetAsync(URL..'/v1/role-status/'..Player.UserId)
	end)

	if response then
		data = HttpService:JSONDecode(data)
		
		if data.data then
			local roles = data.data
			if table.find(roles, 'Alliance_Rep') and Player:GetRankInGroup(6975354) < 256 then -- normally 40
				return true
			end
		end
	end
end

return SakuraModule