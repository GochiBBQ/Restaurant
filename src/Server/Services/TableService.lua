--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableClass = require(Knit.Classes.Table) --- @module Table
local TableMap = require(Knit.Structures.TableMap) --- @module TableMap

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

-- Server Functions
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
end

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
        return result
    else
        return false
    end
end

function TableService:RemoveOccupantFromTable(tableInstance, occupant)
    local tableObj = Tables:get(tableInstance)
    if tableObj then
        return tableObj:_removeOccupant(tableInstance, occupant)
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
function TableService.Client:SetOccupied(Server: Player, Table: Instance, Occupants: {Player})
    return self.Server:SetTableOccupied(Server, Table, Occupants)
end

function TableService.Client:SetUnoccupied(Player: Player, Table: Instance)
    return self.Server:SetTableUnoccupied(Table)
end

function TableService.Client:AddOccupant(Player: Player, Table: Instance, Occupant: Player)
    return self.Server:AddOccupantToTable(Table, Occupant)
end

function TableService.Client:RemoveOccupant(Player: Player, Table: Instance, Occupant: Player)
    return self.Server:RemoveOccupantFromTable(Table, Occupant)
end

function TableService.Client:GetOccupants(Player: Player, Table: Instance)
    return self.Server:GetTableOccupants(Table)
end

function TableService.Client:GetAvailable(Player: Player, Seats: number)
    return self.Server:GetAvailableTables(Seats)
end

function TableService.Client:GetCount(Player: Player)
    return self.Server:GetTableCount()
end

function TableService.Client:Claim(Server: Player, Area: string, Seats: number)
    return self.Server:ClaimTable(Server, Area, Seats)
end

function TableService.Client:GetInfo(Player: Player, Table: Instance | string)
    return self.Server:GetTableInfo(Table)
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

-- Return Service to Knit.
return TableService
