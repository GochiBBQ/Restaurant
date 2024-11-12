--[[

█▀▀█ █░░ █▀▀█ █▀▀ █▀▀█ █▀▀▄ █░░█ █▀▀ █▀▀█ █▀▀▄ █▀▀ 
█▄▄█ █░░ █▄▄▀ █▀▀ █▄▄█ █░░█ █▄▄█ █▀▀ █▄▄█ █░░█ ▀▀█ 
▀░░▀ ▀▀▀ ▀░▀▀ ▀▀▀ ▀░░▀ ▀▀▀░ ▄▄▄█ ▀░░ ▀░░▀ ▀░░▀ ▀▀▀

Author: alreadyfans
For: Fiésta

]]

local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")

return function (data)
    return 'gm',
    function (args)
        local player = args[1]
        local combinedArgs = ""

        if not args[3] then return end
		for a,b in pairs(args) do
			if a > 2 then
				combinedArgs = combinedArgs..b..' '
			end
		end
		
		data[1]:FireAllClients('Message', 'Global Announcement from '..player.Name, combinedArgs)
		data[1]:FireClient(player, 'Notif', 'System', 'Successfully announced in all servers.', {})
		MessagingService:PublishAsync('BAE_GA_DEV', {Player = player.Name, Message = combinedArgs, JobId = game.JobId})
	
		
		MessagingService:SubscribeAsync("BAE_GA_DEV", function(data)
			if data.JobId == game.JobId then return end
			data[1]:FireAllClients('Message', 'Global Announcement from '..data.Player, data.Message)
		end)
	end,
    3, data[5], {"gm", "<Message>", "Make a global announcement"}   
end