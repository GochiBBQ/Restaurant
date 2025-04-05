--[[
Author: alreadyfans
For: Gochi
]]

-- Class Init
local Table = {}
Table.__index = Table
Table.__loaded = false

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove
local TableMap

-- Variables
local NotificationService

local Tables
local SeatTrove

local TableCount = {
	["Indoor Dining"] = 0,
	["Terrace Dining"] = 0,
	["Underwater Dining"] = 0
}

Knit.OnStart():andThen(function()
	NotificationService = Knit.GetService("NotificationService")
    TableMap = require(Knit.Structures.TableMap) --- @module TableMap

    Tables = TableMap.new() -- TableInstance → TableData
    SeatTrove = TableMap.new() -- TableInstance → Trove
end)

-- Constructor
function Table.new(tab: Instance, Category: string, Seats: number)
    repeat task.wait() until Tables ~= nil and SeatTrove ~= nil
    if not tab:IsA("Model") then error("Table.new() requires a Model instance.") end
    
	local self = setmetatable({}, Table)

	self.Table = tab
	self.Name = tab.Name
	self.Category = Category
	self.Seats = tonumber(Seats)

	Tables:set(tab, {
		Table = self.Table,
		Name = self.Name,
		Seats = tonumber(self.Seats),
		Category = self.Category,
		isOccupied = false,
		Server = nil,
		Occupants = {},
	})

	TableCount[Category] += 1

	local trove = Trove.new()
	SeatTrove:set(tab, trove)

	for _, object in pairs(tab:GetDescendants()) do
		if object:IsA("Seat") then
			trove:Connect(object:GetPropertyChangedSignal("Occupant"), function()
				if object.Occupant then
					local player = Players:GetPlayerFromCharacter(object.Occupant.Parent)
					local humanoid = object.Occupant

					if not player then return end

					local denyPermission = function()
						NotificationService:_createNotif(player, "You do not have permission to sit at this table.")
						task.delay(0.1, function()
							humanoid.Jump = true
						end)
					end

					local tableData = Tables:get(tab)
					if not tableData or not tableData.isOccupied or not table.find(tableData.Occupants, player) then
						denyPermission()
					end
				end
			end)
		end
	end

	return self
end

-- Methods
function Table:_getTableCount()
    
    repeat task.wait() until self.__loaded
    
	return TableCount
end

function Table:_claimTable(Server: Player, Area: string, Seats: number)
	local availableTables = self:_getAvailableTables(Area, Seats)
	if #availableTables == 0 then
		return false, "No available tables in this area."
	end

	table.sort(availableTables, function(a, b)
		local aSeats = tonumber(Tables:get(a).Seats)
		local bSeats = tonumber(Tables:get(b).Seats)
		local diffA = math.abs(aSeats - Seats)
		local diffB = math.abs(bSeats - Seats)
		return diffA < diffB
	end)

	local tableInstance = availableTables[1]
	local tableData = Tables:get(tableInstance)

	if not tableData then
		return false, "Table data not found."
	end

	tableData.Server = Server
	Server:SetAttribute("Table", tableData.Name)
	Server:SetAttribute("Server", true)

	return true, tableData
end

function Table:_checkOccupied(TableInst: Instance)
	local data = Tables:get(TableInst)
	return data and data.isOccupied, data and data.Occupants
end

function Table:_setOccupied(Server: Player, TableInst: Instance, Occupants: { Player })
	local data = Tables:get(TableInst)
	if not data then return false, "Table not found." end

	if #Occupants > tonumber(data.Seats) then
		return false, "Occupants exceeds table seat limit."
	end

	if data.Server ~= Server then
		return false, "Table is already claimed by another server."
	end

	if data.isOccupied then
		return false, "Table is already occupied."
	end

	for _, occupant in pairs(Occupants) do
		if not occupant:IsA("Player") then
			return false, "Occupants must be players."
		end
	end

	data.isOccupied = true
	data.Occupants = Occupants

	for _, p in pairs(Occupants) do
		p:SetAttribute("Table", data.Name)
		p:SetAttribute("InParty", true)
	end

	return true
end

function Table:_setUnoccupied(TableInst: Instance)
	local data = Tables:get(TableInst)
	if not data then return false, "Table not found." end

	data.isOccupied = false

	if data.Server then
		data.Server:SetAttribute("Table", nil)
	end

	if #data.Occupants > 0 then
		for _, p in pairs(data.Occupants) do
			if p:IsA("Player") then
				p:SetAttribute("Table", nil)
				p:SetAttribute("InParty", false)
			end
		end
	end

	data.Server = nil
	data.Occupants = {}

	return true
end

function Table:_addOccupant(TableInst: Instance, Player: Player)
	local data = Tables:get(TableInst)
	if not data then return false, "Table not found." end

	if not data.isOccupied then return false, "Table is not occupied." end
	if #data.Occupants >= tonumber(data.Seats) then return false, "Table is full." end

	table.insert(data.Occupants, Player)
	Player:SetAttribute("Table", data.Name)
	Player:SetAttribute("InParty", true)

	return true
end

function Table:_removeOccupant(TableInst: Instance, Player: Player)
	local data = Tables:get(TableInst)
	if not data then return false, "Table not found." end

	if not data.isOccupied then return false, "Table is not occupied." end

	local index = table.find(data.Occupants, Player)
	if not index then return false, "Occupant not found." end

	table.remove(data.Occupants, index)
	Player:SetAttribute("Table", nil)
	Player:SetAttribute("InParty", false)

	if #data.Occupants == 0 then
		self:_setUnoccupied(TableInst)
	end

	return true
end

function Table:_getOccupants(TableInst: Instance)
	local data = Tables:get(TableInst)
	return data and data.Occupants
end

function Table:_getServer(TableInst: Instance)
	local data = Tables:get(TableInst)
	return data and data.Server
end

function Table:_getAvailableTables(Area: string, Seats: number)
	local results = {}

	for tableInstance, data in Tables:entries() do
		if data.Category == Area
			and not data.isOccupied
			and not data.Server
			and tonumber(data.Seats) >= tonumber(Seats)
		then
			table.insert(results, tableInstance)
		end

	end

	return results
end

function Table:_getTableInfo(TableInst: Instance)
	return Tables:get(TableInst)
end

function Table:_destroy(TableInst: Instance)
	local trove = SeatTrove:get(TableInst)
	if trove then
		trove:Clean()
		SeatTrove:remove(TableInst)
	end

	Tables:remove(TableInst)
end

return Table
