--[[
Author: alreadyfans
For: Gochi
]]

-- Class Init
local Table = {}
Table.__index = Table

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Variables
local NotificationService

local Tables = {}
local TableCount = {
    ["Indoor Dining"] = 0,
    ["Terrace Dining"] = 0,
    ["Underwater Dining"] = 0
}

local SeatTrove = {} -- Stores Troves for each table's seat connections

Knit.OnStart():andThen(function()
    NotificationService = Knit.GetService("NotificationService")
end)

-- Functions
function Table.new(tab: Instance, Category: string, Seats: number)
    local self = setmetatable({}, Table)

    self.Table = tab
    self.Name = tab.Name
    self.Category = Category
    self.Seats = Seats

    Tables[tab] = {
        Table = self.Table,
        Name = self.Name,
        Seats = self.Seats,
        Category = self.Category,
        isOccupied = false,
        Server = nil,
        Occupants = {}
    }

    TableCount[Category] = TableCount[Category] + 1

    local trove = Trove.new()
    SeatTrove[tab] = trove

    for _, object in pairs(tab:GetDescendants()) do
        if object:IsA("Seat") then
            trove:Connect(object:GetPropertyChangedSignal("Occupant"), function()
                if object.Occupant then
                    local Player = Players:GetPlayerFromCharacter(object.Occupant.Parent)
                    local Humanoid = object.Occupant

                    local function denyPermission()
                        NotificationService:_createNotif(Player, "You do not have permission to sit at this table.")
                        task.delay(0.1, function()
                            Humanoid.Jump = true
                        end)
                    end

                    if not Tables[tab].isOccupied or not table.find(Tables[tab].Occupants, Player) then
                        denyPermission()
                    end
                end
            end)
        end
    end

    return self
end

function Table:_getTableCount()
    return TableCount
end

function Table:_claimTable(Server: Player, Area: string, Seats: number)
    local availableTables = self:_getAvailableTables(Area, Seats)

    if #availableTables == 0 then
        return false, "No available tables in this area."
    end

    table.sort(availableTables, function(a, b)
        local diffA = math.abs(Tables[a].Seats - Seats)
        local diffB = math.abs(Tables[b].Seats - Seats)
        return diffA < diffB
    end)

    local tableInstance = availableTables[1]
    local tableData = Tables[tableInstance]

    if not tableData then
        return false, "Table data not found."
    end

    tableData.Server = Server
    Server:SetAttribute("Table", tableData.Name)

    return true, tableData
end

function Table:_checkOccupied(Table: Instance)
    return Tables[Table].isOccupied, Tables[Table].Occupants
end

function Table:_setOccupied(Server: Player, Table: Instance, Occupants: {Player})
    if #Occupants > Tables[Table].Seats then
        return false, "Occupants exceeds table seat limit."
    end

    if Tables[Table].Server ~= Server then
        return false, "Table is already claimed by another server."
    end

    if Tables[Table].isOccupied then
        return false, "Table is already occupied."
    end

    for _, Occupant in pairs(Occupants) do
        if not Occupant:IsA("Player") then
            return false, "Occupants must be players."
        end
    end

    Tables[Table].isOccupied = true
    Tables[Table].Occupants = Occupants

    for _, Occupant in pairs(Occupants) do
        if Occupant:IsA("Player") then
            Occupant:SetAttribute("Table", Tables[Table].Name)
            Occupant:SetAttribute("InParty", true)
        end
    end

    return true
end

function Table:_setUnoccupied(Table: Instance)
    if not Tables[Table].isOccupied then
        return false, "Table is not occupied."
    end

    Tables[Table].isOccupied = false
    if Tables[Table].Server then
        Tables[Table].Server:SetAttribute("Table", nil)
    end
    Tables[Table].Server = nil

    for _, Occupant in pairs(Tables[Table].Occupants) do
        if Occupant:IsA("Player") then
            Occupant:SetAttribute("Table", nil)
            Occupant:SetAttribute("InParty", false)
        end
    end

    Tables[Table].Occupants = {}
    return true
end

function Table:_addOccupant(Table: Instance, Occupant: Player)
    if not Tables[Table].isOccupied then
        return false, "Table is not occupied."
    end

    if #Tables[Table].Occupants >= Tables[Table].Seats then
        return false, "Table is full."
    end

    table.insert(Tables[Table].Occupants, Occupant)
    Occupant:SetAttribute("Table", Tables[Table].Name)
    Occupant:SetAttribute("InParty", true)
    return true
end

function Table:_removeOccupant(Table: Instance, Occupant: Player)
    print("Removing occupant from table:", Table.Name, "Occupant:", Occupant.Name)

    if not Tables[Table].isOccupied then
        return false, "Table is not occupied."
    end

    local index = table.find(Tables[Table].Occupants, Occupant)
    if index then
        table.remove(Tables[Table].Occupants, index)
        Occupant:SetAttribute("Table", nil)
        Occupant:SetAttribute("InParty", false)

        if #Tables[Table].Occupants == 0 then
            self:_setUnoccupied(Table)
        end

        return true
    else
        return false, "Occupant not found."
    end
end

function Table:_getOccupants(Table: Instance)
    return Tables[Table].Occupants
end

function Table:_getServer(Table: Instance)
    return Tables[Table].Server
end

function Table:_getAvailableTables(Area: string, Seats: number)
    local availableTables = {}
    local seatsNumber = tonumber(Seats)

    for tableInstance, tableData in pairs(Tables) do
        if tableData.Category == Area and not tableData.isOccupied and not tableData.Server and tableData.Seats >= seatsNumber then
            table.insert(availableTables, tableInstance)
        end
    end

    return availableTables
end

function Table:_getTableInfo(Table: Instance)
    return Tables[Table]
end

function Table:_destroy(Table: Instance)
    if SeatTrove[Table] then
        SeatTrove[Table]:Clean()
        SeatTrove[Table] = nil
    end

    Tables[Table] = nil
end

return Table
