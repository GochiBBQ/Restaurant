--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage: ServerStorage = game:GetService("ServerStorage")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local TableClass: ModuleScript = require(Knit.Classes.Table)
local TableMap: ModuleScript = require(ServerScriptService.Structures.TableMap)

-- Create Knit Service
local TableService = Knit.CreateService {
    Name = "TableService",
    Client = {
        TableOccupied = Knit.CreateSignal(),
        TableUnoccupied = Knit.CreateSignal(),
        OccupantAdded = Knit.CreateSignal(),
        OccupantRemoved = Knit.CreateSignal(),
        UpdateCount = Knit.CreateSignal()
    },
}

-- Variables
local TableFolder: Folder = workspace:WaitForChild("Functionality"):WaitForChild("Tables")
local Tables = TableMap.new()

local DisconnectedPlayers: table = {} -- [UserId] = { timestamp, table, wasServer }
local RejoinGraceTime: IntValue = 60 -- seconds

-- Knit Start
function TableService:KnitStart()

	if not TableFolder then
		warn("TableService: TableFolder not found.")
		return
	end

	for _, categoryFolder in pairs(TableFolder:GetChildren()) do
		for _, tableInstance in pairs(categoryFolder:GetChildren()) do
			local seats = tableInstance:GetAttribute("Seats") or 4
			local category = categoryFolder.Name
			local newTable = TableClass.new(tableInstance, category, seats)
			Tables:set(tableInstance, newTable)
		end
	end

	TableClass.__loaded = true
	self:StartIntegrityLoop()

	Players.PlayerRemoving:Connect(function(player)
		for tableInstance, tableObj in Tables:entries() do
			local data = tableObj:_getTableInfo(tableInstance)
			if not data then continue end

			local wasOccupant = table.find(data.Occupants, player)
			local wasServer = (data.Server == player)

			if wasOccupant or wasServer then
				DisconnectedPlayers[player.UserId] = {
					timestamp = os.time(),
					table = tableInstance,
					wasServer = wasServer
				}

				-- Delay cleanup unless they rejoin
				task.delay(RejoinGraceTime, function()
					local info = DisconnectedPlayers[player.UserId]
					if info and os.time() - info.timestamp >= RejoinGraceTime then
						local tableObj = Tables:get(info.table)
						if tableObj then
							if info.wasServer then
								tableObj:_setUnoccupied(info.table)
							else
								tableObj:_removeOccupant(info.table, player)
							end
							TableService.Client.UpdateCount:FireAll()
						end
						DisconnectedPlayers[player.UserId] = nil
					end
				end)
			end
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		local info = DisconnectedPlayers[player.UserId]
		if not info then return end

		local tableObj = Tables:get(info.table)
		if not tableObj then return end

		local data = tableObj:_getTableInfo(info.table)
		if not data or not data.isOccupied then return end

		if info.wasServer then
			if not data.Server then
				data.Server = player
				player:SetAttribute("Table", data.Name)
				player:SetAttribute("Server", true)
				print(`[Reconnect] Restored {player.Name} as server of {info.table.Name}`)
			end
		else
			if #data.Occupants >= tonumber(data.Seats) then
				warn(`[Reconnect] {player.Name} could not rejoin {info.table.Name} — table is full`)
			elseif not table.find(data.Occupants, player) then
				local success = tableObj:_addOccupant(info.table, player)
				if success then
					print(`[Reconnect] Restored {player.Name} to table {info.table.Name}`)
				end
			end
		end

		DisconnectedPlayers[player.UserId] = nil
	end)
end

-- Integrity Loop
function TableService:StartIntegrityLoop()
	task.spawn(function()
		while true do
			task.wait(5)
			local updated = false

			for tableInstance, tableObj in Tables:entries() do
				local data = tableObj:_getTableInfo(tableInstance)
				if not data then continue end

				local validOccupants = {}
				for _, player in ipairs(data.Occupants) do
					if player and player:IsA("Player") and Players:FindFirstChild(player.Name) then
						table.insert(validOccupants, player)
					end
				end

				if data.isOccupied and data.Server == nil then
					warn(`[Integrity] {tableInstance.Name} is occupied but has no server`)
					tableObj:_setUnoccupied(tableInstance)
					updated = true
				elseif data.isOccupied and #validOccupants == 0 then
					warn(`[Auto-Fix] Vacating {tableInstance.Name} — no valid occupants`)
					tableObj:_setUnoccupied(tableInstance)
					updated = true
				end
			end

			if updated then
				TableService.Client.UpdateCount:FireAll()
			end
		end
	end)
end

-- Server Methods
function TableService:GetTableCount()
	return TableClass:_getTableCount()
end

function TableService:ClaimTable(Server, Area, Seats)
	return TableClass:_claimTable(Server, Area, Seats)
end

function TableService:SetTableOccupied(Server, tableInstance, occupants)
	local tableObj = Tables:get(tableInstance)
	if tableObj then
		local result = tableObj:_setOccupied(Server, tableInstance, occupants)
		TableService.Client.UpdateCount:FireAll()
		return result
	else
		return false
	end
end

function TableService:SetTableUnoccupied(tableInstance)
	local tableObj = Tables:get(tableInstance)
	if tableObj then
		local result = tableObj:_setUnoccupied(tableInstance)
		TableService.Client.UpdateCount:FireAll()
		return result
	else
		return false
	end
end

function TableService:AddOccupantToTable(tableInstance, occupant)
	local tableObj = Tables:get(tableInstance)
	if tableObj then
		local result = tableObj:_addOccupant(tableInstance, occupant)
		TableService.Client.UpdateCount:FireAll()
		return result
	else
		return false
	end
end

function TableService:RemoveOccupantFromTable(tableInstance, occupant)
	local tableObj = Tables:get(tableInstance)
	if tableObj then
		local result = tableObj:_removeOccupant(tableInstance, occupant)
		TableService.Client.UpdateCount:FireAll()
		return result
	else
		return false
	end
end

function TableService:GetTableOccupants(tableInstance)
	if typeof(tableInstance) == "string" then
		for instance in Tables:entries() do
			if instance.Name == tableInstance then
				tableInstance = instance
				break
			end
		end
	end

	local tableObj = Tables:get(tableInstance)
	if tableObj then
		return tableObj:_getOccupants(tableInstance)
	else
		return false
	end
end

function TableService:GetAvailableTables(Seats)
	return TableClass:_getAvailableTables(Seats)
end

function TableService:GetTableInfo(tableInstance)
	if typeof(tableInstance) == "string" then
		for instance in Tables:entries() do
			if instance.Name == tableInstance then
				tableInstance = instance
				break
			end
		end
	end

	local tableObj = Tables:get(tableInstance)
	if tableObj then
		return tableObj:_getTableInfo(tableInstance)
	else
		return false
	end
end

-- Client Functions
function TableService.Client:SetOccupied(Player, Table, Occupants)
	return self.Server:SetTableOccupied(Player, Table, Occupants)
end

function TableService.Client:SetUnoccupied(Player, Table)
	return self.Server:SetTableUnoccupied(Table)
end

function TableService.Client:AddOccupant(Player, Table, Occupant)
	return self.Server:AddOccupantToTable(Table, Occupant)
end

function TableService.Client:RemoveOccupant(Player, Table, Occupant)
	return self.Server:RemoveOccupantFromTable(Table, Occupant)
end

function TableService.Client:GetOccupants(Player, Table)
	return self.Server:GetTableOccupants(Table)
end

function TableService.Client:GetAvailable(Player, Seats)
	return self.Server:GetAvailableTables(Seats)
end

function TableService.Client:GetCount(Player)
	return self.Server:GetTableCount()
end

function TableService.Client:Claim(Player, Area, Seats)
	return self.Server:ClaimTable(Player, Area, Seats)
end

function TableService.Client:GetInfo(Player, Table)
	return self.Server:GetTableInfo(Table)
end

return TableService
