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

local MessagingService = game:GetService("MessagingService")
local ChatService = game:GetService("Chat")

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
	local pluginName = 'global'
	local pluginPrefix = Prefix
	local pluginLevel = 3
	local pluginUsage = "<Message>" -- leave blank if the command has no arguments
	local pluginDescription = "Send a message to all active servers."

	-- Warning Plugin Function --
	local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
		local Player = Args[1]
		if not Args[3] then return remoteEvent:FireClient(Player, "Hint", "Player Not Found", "You must type in a message to send to the server.") end
		local combinedArgs = ''
		for i,v in pairs(Args) do
			if i > 2 then
				combinedArgs = combinedArgs..v..' '
			end
		end
		
		combinedArgs = ChatService:FilterStringForBroadcast(combinedArgs, Player)
		MessagingService:PublishAsync("Global_Announcement", {[1] = Player.Name, [2] = combinedArgs})
	end
	
	if not game:GetService("RunService"):IsStudio() then
		MessagingService:SubscribeAsync("Global_Announcement", function(Message)
			remoteEvent:FireAllClients('Message','Global Message from ' .. Message.Data[1],Message.Data[2])
		end)
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