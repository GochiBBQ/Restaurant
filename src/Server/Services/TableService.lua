--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableClass = require(Knit.Classes.Table)
local TableMap = require(Knit.Structures.TableMap)

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
local Tables = TableMap.new()
local Animations = ServerStorage:WaitForChild("Animations")
local ongoingAnimations = TableMap.new()

local DisconnectedPlayers = {} -- [UserId] = { timestamp, table, wasServer }
local RejoinGraceTime = 60 -- seconds

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
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChild("Humanoid")
	local ModelRoot = Model:FindFirstChild("HumanoidRootPart")

	if not HRP or not Humanoid or not ModelRoot then return end

	if State then
		Humanoid.WalkSpeed = 0
		Humanoid.JumpPower = 0
		Humanoid.PlatformStand = true
		HRP.Anchored = true
		HRP.CFrame = ModelRoot.CFrame
	else
		Humanoid.PlatformStand = false
		HRP.Anchored = false
		Humanoid.WalkSpeed = (Player:GetAttribute("Walkspeed") and 32) or 16
		Humanoid.JumpPower = 50
	end
end

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
	return TableService.Server:SetTableOccupied(Player, Table, Occupants)
end

function TableService.Client:SetUnoccupied(Player, Table)
	return TableService.Server:SetTableUnoccupied(Table)
end

function TableService.Client:AddOccupant(Player, Table, Occupant)
	return TableService.Server:AddOccupantToTable(Table, Occupant)
end

function TableService.Client:RemoveOccupant(Player, Table, Occupant)
	return TableService.Server:RemoveOccupantFromTable(Table, Occupant)
end

function TableService.Client:GetOccupants(Player, Table)
	return TableService.Server:GetTableOccupants(Table)
end

function TableService.Client:GetAvailable(Player, Seats)
	return TableService.Server:GetAvailableTables(Seats)
end

function TableService.Client:GetCount(Player)
	return TableService.Server:GetTableCount()
end

function TableService.Client:Claim(Player, Area, Seats)
	return TableService.Server:ClaimTable(Player, Area, Seats)
end

function TableService.Client:GetInfo(Player, Table)
	return TableService.Server:GetTableInfo(Table)
end

function TableService.Client:TabletInit(Player, Tablet)
	assert(Player:IsA("Player"))
	assert(Tablet:IsA("Model"))

	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Animation = LoadAnimation(Character, Animations.TabletInit)

	local current = ongoingAnimations:get(Player)
	if current then current:Stop() end

	Tablet:SetAttribute("InUse", true)
	ongoingAnimations:set(Player, Animation)

	LockPlayerToModel(Player, Tablet, true)
	Animation:Play()
end

function TableService.Client:TabletEnd(Player, Tablet)
	assert(Player:IsA("Player"))

	local anim = ongoingAnimations:get(Player)
	if not anim then return end

	anim:Stop()
	ongoingAnimations:remove(Player)

	Tablet:SetAttribute("InUse", false)
	LockPlayerToModel(Player, Tablet, false)
end

return TableService
