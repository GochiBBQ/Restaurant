--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) --@module Knit
local TableClass = require(Knit.Classes.Table) --@module Table
local TableMap = require(Knit.Structures.TableMap) --@module TableMap

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
local TableFolder = workspace:WaitForChild("Functionality"):WaitForChild("Tables")
local Tables = TableMap.new() -- Instance → TableClass
local Animations = ServerStorage:WaitForChild("Animations")
local ongoingAnimations = TableMap.new() -- Player → AnimationTrack

-- Utility
local function LoadAnimation(Character: Instance, Animation: Animation)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		if Animator then
			local AnimationTrack = Animator:LoadAnimation(Animation)
			return AnimationTrack
		end
	end
end

local function LockPlayerToModel(Player: Player, Model: Model, State: boolean)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChild("Humanoid")
	local ModelRoot = Model:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart or not Humanoid or not ModelRoot then return end

	if State then
		Humanoid.WalkSpeed = 0
		Humanoid.JumpPower = 0
		Humanoid.PlatformStand = true
		HumanoidRootPart.Anchored = true
		HumanoidRootPart.CFrame = ModelRoot.CFrame
	else
		Humanoid.PlatformStand = false
		HumanoidRootPart.Anchored = false
		Humanoid.WalkSpeed = (Player:GetAttribute("Walkspeed") and 32) or 16
		Humanoid.JumpPower = 50
	end
end

-- Knit Start
function TableService:KnitStart()
	if not TableFolder then
		warn("TableService:KnitStart() - TableFolder not found.")
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
			if data then
				local index = table.find(data.Occupants, player)
				if index then
					print(`[Disconnect Cleanup] Removing {player.Name} from table {tableInstance.Name}`)
					tableObj:_removeOccupant(tableInstance, player)
					TableService.Client.UpdateCount:FireAll()
				end

				if data.Server == player then
					print(`[Disconnect Cleanup] {player.Name} was the server for table {tableInstance.Name}`)
					tableObj:_setUnoccupied(tableInstance)
					TableService.Client.UpdateCount:FireAll()
				end
			end
		end
	end)
end

function TableService:StartIntegrityLoop()
	task.spawn(function()
		while true do
			task.wait(5) -- Adjust interval as needed
			local updated = false

			for tableInstance, tableObj in Tables:entries() do
				local data = tableObj:_getTableInfo(tableInstance)
				if not data then continue end

				local occupantCount = #data.Occupants
				local validOccupants = {}

				for _, player in ipairs(data.Occupants) do
					if player and player:IsA("Player") and Players:FindFirstChild(player.Name) then
						table.insert(validOccupants, player)
					end
				end

				-- Detect issues
				if data.isOccupied and occupantCount == 0 then
					warn(`[Integrity Check] Table {tableInstance.Name} is occupied with 0 occupants`)
				end

				if #validOccupants < occupantCount then
					warn(`[Integrity Check] Table {tableInstance.Name} has invalid occupants`)
				end

				if data.isOccupied and data.Server == nil then
					warn(`[Integrity Check] Table {tableInstance.Name} has no server assigned but is occupied`)
					tableObj:_setUnoccupied(tableInstance)
					updated = true
				elseif data.isOccupied and #validOccupants == 0 then
					warn(`[Auto-Fix] Vacating table {tableInstance.Name} (no valid occupants)`)
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

-- Server Functions
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
		for instance, _ in Tables:entries() do
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
		for instance, _ in Tables:entries() do
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
function TableService.Client:SetOccupied(Player: Player, Table: Instance, Occupants: {Player})
	return TableService.Server:SetTableOccupied(Player, Table, Occupants)
end

function TableService.Client:SetUnoccupied(Player: Player, Table: Instance)
	return TableService.Server:SetTableUnoccupied(Table)
end

function TableService.Client:AddOccupant(Player: Player, Table: Instance, Occupant: Player)
	return TableService.Server:AddOccupantToTable(Table, Occupant)
end

function TableService.Client:RemoveOccupant(Player: Player, Table: Instance, Occupant: Player)
	return TableService.Server:RemoveOccupantFromTable(Table, Occupant)
end

function TableService.Client:GetOccupants(Player: Player, Table: Instance)
	return TableService.Server:GetTableOccupants(Table)
end

function TableService.Client:GetAvailable(Player: Player, Seats: number)
	return TableService.Server:GetAvailableTables(Seats)
end

function TableService.Client:GetCount(Player: Player)
	return TableService.Server:GetTableCount()
end

function TableService.Client:Claim(Player: Player, Area: string, Seats: number)
	return TableService.Server:ClaimTable(Player, Area, Seats)
end

function TableService.Client:GetInfo(Player: Player, Table: Instance | string)
	return TableService.Server:GetTableInfo(Table)
end

function TableService.Client:TabletInit(Player: Player, Tablet: Instance)
	assert(Player:IsA("Player"), "Player must be a Player instance.")
	assert(Tablet:IsA("Model"), "Tablet must be a Model instance.")

	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Animation = LoadAnimation(Character, Animations.TabletInit)

	local current = ongoingAnimations:get(Player)
	if current then current:Stop() end

	Tablet:SetAttribute("InUse", true)
	ongoingAnimations:set(Player, Animation)

	LockPlayerToModel(Player, Tablet, true)
	Animation:Play()
end

function TableService.Client:TabletEnd(Player: Player, Tablet: Instance)
	assert(Player:IsA("Player"), "Player must be a Player instance.")

	local anim = ongoingAnimations:get(Player)
	if not anim then return end

	anim:Stop()
	ongoingAnimations:remove(Player)

	Tablet:SetAttribute("InUse", false)
	LockPlayerToModel(Player, Tablet, false)
end

-- Return Service to Knit
return TableService