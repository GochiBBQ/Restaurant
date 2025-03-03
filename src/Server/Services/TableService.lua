--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Table = require(Knit.Classes.Table) --- @module Table

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
local Tables = {}

local TabletAnimation = 'rbxassetid://116598436795374'

-- Server Functions

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

function TableService:KnitStart()
    if not TableFolder then
        warn("TableService:KnitStart() - TableFolder not found.")
        return
    end

    for _, categoryFolder in pairs(TableFolder:GetChildren()) do
        for _, tableInstance in pairs(categoryFolder:GetChildren()) do
            local seats = tableInstance:GetAttribute("Seats") or 4 -- Default to 4 seats if not specified
            local category = categoryFolder.Name
            local newTable = Table.new(tableInstance, category, seats)
            Tables[tableInstance] = newTable
        end
    end

    self.Client.UpdateCount:FireAll(self:GetTableCount())
    self.Client.TableOccupied:FireAll("hi")
end

function TableService:GetTableCount()
    return Table:_getTableCount()
end

function TableService:SetTableOccupied(tableInstance, occupants)
    local tableObj = Tables[tableInstance]
    if tableObj then
        local result = tableObj:_setOccupied(tableInstance, occupants)
        if result == nil then
            self.Client.TableOccupied:Fire(tableInstance, occupants)
        end
        return result
    else
        return "Table not found."
    end
end

function TableService:SetTableUnoccupied(tableInstance)
    local tableObj = Tables[tableInstance]
    if tableObj then
        tableObj:_setUnoccupied(tableInstance)
        self.Client.TableUnoccupied:Fire(tableInstance)
    else
        return "Table not found."
    end
end

function TableService:AddOccupantToTable(tableInstance, occupant)
    local tableObj = Tables[tableInstance]
    if tableObj then
        local result = tableObj:_addOccupant(tableInstance, occupant)
        if result == nil then
            self.Client.OccupantAdded:Fire(tableInstance, occupant)
        end
        return result
    else
        return "Table not found."
    end
end

function TableService:RemoveOccupantFromTable(tableInstance, occupant)
    local tableObj = Tables[tableInstance]
    if tableObj then
        local result = tableObj:_removeOccupant(tableInstance, occupant)
        if result == "Occupant removed." then
            self.Client.OccupantRemoved:Fire(tableInstance, occupant)
        end
        return result
    else
        return "Table not found."
    end
end

function TableService:GetTableOccupants(tableInstance)
    local tableObj = Tables[tableInstance]
    if tableObj then
        return tableObj:_getOccupants(tableInstance)
    else
        return "Table not found."
    end
end

function TableService:GetAvailableTables(Seats)
    return Table:_getAvailableTables(Seats)
end

function TableService:GetTableInfo(tableInstance)
    local tableObj = Tables[tableInstance]
    if tableObj then
        return tableObj:_getTableInfo(tableInstance)
    else
        return "Table not found."
    end
end

-- Client Functions
function TableService.Client:SetOccupied(Player: Player, Table: Instance, Occupants: {Player})
    return self.Server:SetTableOccupied(Table, Occupants)
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

function TableService.Client:GetInfo(Player: Player, Table: Instance)
    return self.Server:GetTableInfo(Table)
end

function TableService.Client:TabletInit(Player: Player, Tablet: Instance)
    assert(Player:IsA("Player"), "Player must be a Player instance.")
    assert(Tablet:IsA("Model"), "Tablet must be a Model instance.")
    
--[[ ## TODO:
        Make animation play when tablet is prompted
]]
end

-- Return Service to Knit.
return TableService