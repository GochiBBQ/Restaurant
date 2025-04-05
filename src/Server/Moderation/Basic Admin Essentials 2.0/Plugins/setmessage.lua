--[[

█▀▀█ █░░ █▀▀█ █▀▀ █▀▀█ █▀▀▄ █░░█ █▀▀ █▀▀█ █▀▀▄ █▀▀ 
█▄▄█ █░░ █▄▄▀ █▀▀ █▄▄█ █░░█ █▄▄█ █▀▀ █▄▄█ █░░█ ▀▀█ 
▀░░▀ ▀▀▀ ▀░▀▀ ▀▀▀ ▀░░▀ ▀▀▀░ ▄▄▄█ ▀░░ ▀░░▀ ▀░░▀ ▀▀▀

Author: alreadyfans
For: Gochí
https://www.roblox.com/groups/5874921/Goch#!/about

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Plugin = function(...)
	local Data = {...}
	
	
	local remoteEvent = Data[1][1]
	local returnPermissions = Data[1][3]
	local Prefix = Data[1][5]
	local cleanData = Data[1][8]
	local Session = require(ReplicatedStorage:WaitForChild("Data").SessionData)
	
	local pluginName = 'n'
	local pluginPrefix = Prefix
	local pluginLevel = 1
	local pluginUsage = "<Message>"
	local pluginDescription = "Display a notification."
	
	local function pluginFunction(Args)
		local executor = Args[1]
		
		local text = table.concat(Args, " ", 3)
		if text == "" then
			return
		end
		
		for _, player in ipairs(Players:GetPlayers()) do
			local cleaned, cleanText = cleanData(text, executor, player)
			if not cleaned then
				cleanText = text:gsub(".", "#")
			end
			
			Session['SetMessage'] = {
				User = executor,
				Message = cleanText
			}
			
			remoteEvent:FireClient(player, "Notification", ("Notification from <b>%s</b>"):format(executor.Name), cleanText)
		end
	end
	
	local descToReturn
	if pluginUsage ~= "" then
		descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
	else
		descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
	end
	
	return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin