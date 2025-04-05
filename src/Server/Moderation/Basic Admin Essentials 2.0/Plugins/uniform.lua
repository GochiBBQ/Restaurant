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

local LayeredClothingTypes = {
    Enum.AccessoryType.DressSkirt,
    Enum.AccessoryType.Jacket,
    Enum.AccessoryType.Pants,
    Enum.AccessoryType.Shirt,
    Enum.AccessoryType.Shorts,
    Enum.AccessoryType.Sweater,
    Enum.AccessoryType.TShirt,
 }

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
	local pluginName = 'uniform'
	local pluginPrefix = Prefix
	local pluginLevel = 1
	local pluginUsage = "<F/M>" -- leave blank if the command has no arguments
	local pluginDescription = "Puts MR uniform on"
	
	-- Example Plugin Function --
	local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
		local Player = Args[1]
        local ShirtID
        local PantsID
		if Args[3] then
			if string.lower(Args[3]) == "m" then
				ShirtID = "http://www.roblox.com/asset/?id=7256693601"
				PantsID = "http://www.roblox.com/asset/?id=7256475669"
			elseif string.lower(Args[3]) == "f" then
				ShirtID = "http://www.roblox.com/asset/?id=7252060241"
				PantsID = "http://www.roblox.com/asset/?id=7252025644"
			else
				ShirtID = "http://www.roblox.com/asset/?id=7256693601"
				PantsID = "http://www.roblox.com/asset/?id=7256475669"
			end
		else
			ShirtID = "http://www.roblox.com/asset/?id=7256693601"
			PantsID = "http://www.roblox.com/asset/?id=7256475669"
		end

		if Player.Character ~= nil then
			local Character = Player.Character

			for _,z in pairs(Character:GetChildren()) do
				if z.ClassName == "ShirtGraphic" or z.ClassName == "Shirt" or z.ClassName == "Pants" then
					z:Destroy()
				elseif z.ClassName == "Accessory" then
					if table.find(LayeredClothingTypes, z.AccessoryType) then
						z:Destroy()
					end
				end
			end

			local UniformShirt = Instance.new("Shirt")
			UniformShirt.ShirtTemplate = ShirtID
			UniformShirt.Parent = Character

			local UniformPants = Instance.new("Pants")
			UniformPants.PantsTemplate = PantsID
			UniformPants.Parent = Character
		end
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