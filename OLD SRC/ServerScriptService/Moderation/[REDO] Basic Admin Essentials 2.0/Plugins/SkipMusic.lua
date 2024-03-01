--[[
	
	 ____                                   
	/\  _`\                    __      
	\ \ \L\ \     __      ____/\_\    ___
	 \ \  _ <'  /'__`\   /',__\/\ \  /'___\
	  \ \ \L\ \/\ \L\.\_/\__, `\ \ \/\ \__/
	   \ \____/\ \__/.\_\/\____/\ \_\ \____\
	    \/___/  \/__/\/_/\/___/  \/_/\/____/
	                                        
	            
	Admin Essentials v2
	Plugin Documentation
	*coming soon^tm
	
	If you have any questions regarding Plugins, contact TheFurryFish.
	
--]]


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Plugin = function(...)
	local Data = {...}
	
	-- Included Functions and Info --
	local remoteEvent = Data[1][1]
	local remoteFunction = Data[1][2]
	local returnPermissions = Data[1][3]
	local Commands = Data[1][4]
	local Prefix = Data[1][5]
	local actionPrefix = Data[1][6]
	local returnPlayers = Data[1][7]
	local cleanData = Data[1][8] -- cleanData(Sender,Receiver,Data)
	-- Practical example, for a gui specifically for a player, from another player
	-- cleanData(Sender,Receiver,"hi") -- You need receiver because it's being sent to everyone
	-- Or for a broadcast (something everyone sees, from one person, to nobody specific)
	-- cleanData(Sender,nil,"hi") -- Receiver is nil because it is a broadcast
	
	-- Plugin Configuration --
	local pluginName = 'skipsong'
	local pluginPrefix = Prefix
	local pluginLevel = 3
	local pluginUsage = "" -- leave blank if the command has no arguments
	local pluginDescription = "Skips the current song on the Gochi Radio."
	
	-- Example Plugin Function --
	local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
		local Player = Args[1]
		local MusicService = Knit.GetService("MusicService")
		MusicService:SkipSong()
	end
	
	-- Return Everything to the MainModule --
	local descToReturn
	if pluginUsage ~= "" then
		descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
	else
		descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
	end
	
	return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin