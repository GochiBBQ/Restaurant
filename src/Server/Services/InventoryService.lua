--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local NametagList = require(Knit.Data.NametagList) -- @module NametagList
local TableMap = require(ServerScriptService.Structures.TableMap) --- @module TableMap

-- Create Knit Service
local InventoryService = Knit.CreateService {
    Name = "InventoryService",
    Client = {
        UpdateInventory = Knit.CreateSignal(),
    },
    Parts = {
        ["Torso"] = { "UpperTorso" },
        ["Right Arm"] = { "RightUpperArm", "RightLowerArm", "RightHand" },
        ["Left Arm"] = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
        ["Right Leg"] = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
        ["Left Leg"] = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
    },
    Equipped = TableMap.new(), -- Player → { Particles, Trails }
}

-- Variables
local PlayerStorage = workspace:WaitForChild("PlayerStorage")
local OverheadService
local RankService

-- Server Functions
function InventoryService:KnitStart()
    OverheadService = Knit.GetService("OverheadService")
    RankService = Knit.GetService("RankService")

    Players.PlayerAdded:Connect(function(Player)
        repeat task.wait() until Player:GetAttribute("Loaded")

        self.Equipped:set(Player, {
            Particles = {},
            Trails = {},
        })

        for _, category in pairs(PlayerStorage:GetChildren()) do
            if not category:FindFirstChild(Player.Name) then
                local folder = Instance.new("Folder")
                folder.Name = Player.Name
                folder.Parent = category
            end
        end

        if RankService:GetRank(Player) >= 16 then
            for _, gradient in next, NametagList do
                self:_update(Player, "Nametags", gradient.Name, true)
            end
        end

        Player.CharacterAdded:Connect(function(character)
            -- Placeholder if any setup logic is added later
        end)
    end)

    Players.PlayerRemoving:Connect(function(Player)
        for _, category in pairs(PlayerStorage:GetChildren()) do
            local folder = category:FindFirstChild(Player.Name)
            if folder then folder:Destroy() end
        end

        self.Equipped:remove(Player)
    end)
end

function InventoryService:_get(Player: Player, Category: string?)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local Profile = Knit.Profiles[Player]
    if not Profile then return end

    return Category and Profile.Data.Inventory[Category] or Profile.Data.Inventory
end

function InventoryService:_update(Player: Player, Category: string, Item: string, add: boolean)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local Profile = Knit.Profiles[Player]
    if not Profile then return end

    local Inventory = Profile.Data.Inventory
    if not Inventory[Category] then return end

    if add then
        if not self:_search(Player, Category, Item) then
            table.insert(Inventory[Category], Item)
            self.Client.UpdateInventory:Fire(Player, Category, Item, add)
            return true
        end
    else
        local index = table.find(Inventory[Category], Item)
        if index then
            table.remove(Inventory[Category], index)
            self.Client.UpdateInventory:Fire(Player, Category, Item, add)
            return true
        end
    end
end

function InventoryService:_search(Player: Player, Category: string, Item: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local Profile = Knit.Profiles[Player]
    if not Profile then return end

    local Inventory = Profile.Data.Inventory
    return Inventory[Category] and table.find(Inventory[Category], Item) ~= nil
end

function InventoryService:_equip(Player: Player, Category: string, Item: string, equip: boolean)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local function EquipNametag(Player, Item)
        OverheadService:StopGradient(Player)
        OverheadService:CreateGradient(Player, Item)
    end

    local Profile = Knit.Profiles[Player]
    if not Profile then return end

    local Inventory = Profile.Data.Inventory
    if equip then
        if self:_search(Player, Category, Item) then
            Inventory.Equipped[Category] = Item
            if Category == "Nametags" then
                EquipNametag(Player, Item)
            end
        end
    else
        -- Add unequip logic here if needed
    end
end

function InventoryService:_getEquipped(Player: Player, Category: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local Profile = Knit.Profiles[Player]
    if not Profile then return end

    return Profile.Data.Inventory.Equipped[Category]
end

-- Client Functions
function InventoryService.Client:Get(Player: Player, Category: string?)
    return self.Server:_get(Player, Category)
end

function InventoryService.Client:Update(Player: Player, Category: string, Item: string, add: boolean)
    return self.Server:_update(Player, Category, Item, add)
end

function InventoryService.Client:Search(Player: Player, Category: string, Item: string)
    return self.Server:_search(Player, Category, Item)
end

function InventoryService.Client:GetEquipped(Player: Player, Category: string)
    return self.Server:_getEquipped(Player, Category)
end

function InventoryService.Client:Equip(Player: Player, Category: string, Item: string, equip: boolean)
    self.Server:_equip(Player, Category, Item, equip)
end

-- Return Service to Knit.
return InventoryService
