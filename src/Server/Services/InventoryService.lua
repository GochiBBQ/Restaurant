--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local NametagList = require(Knit.Data.NametagList) -- @module NametagList

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
	Equipped = {},
}

-- Variables
local ParticlesFolder = nil
local TrailsFolder = nil
local PlayerStorage = workspace:WaitForChild("PlayerStorage")

local OverheadService
local RankService

-- Server Functions
function InventoryService:KnitStart()
    OverheadService = Knit.GetService("OverheadService")
    RankService = Knit.GetService("RankService")

    Players.PlayerAdded:Connect(function(Player)
        repeat task.wait() until Player:GetAttribute("Loaded")

        self.Equipped[Player] = {
            Particles = {},
            Trails = {},
        }

        for _, category in pairs(PlayerStorage:GetChildren()) do
            if not category:FindFirstChild(Player.Name) then
                local folder = Instance.new("Folder", category)
                folder.Name = Player.Name
            end
        end

        if RankService:GetRank(Player) >= 16 then
            for _, gradient in next, NametagList do
                self:_update(Player, "Nametags", gradient.Name, true)
            end
        end

        Player.CharacterAdded:Connect(function(character)
            
        end)
    end)

    Players.PlayerRemoving:Connect(function(Player)
		for _, category in pairs(PlayerStorage:GetChildren()) do
			if category:FindFirstChild(Player.Name) then
				category:FindFirstChild(Player.Name):Destroy()
			end
		end
	end)
end

function InventoryService:_get(Player: Player, Category: string?)

    repeat task.wait() until Player:GetAttribute("Loaded")

    if Knit.Profiles[Player] then
        local Profile = Knit.Profiles[Player]

        if Category then
            return Profile.Data.Inventory[Category]
        else
            return Profile.Data.Inventory
        end

        return nil
    end
end

function InventoryService:_update(Player: Player, Category: string, Item: string, add: boolean)

    repeat task.wait() until Player:GetAttribute("Loaded")

    if Knit.Profiles[Player] then
        local Inventory = Knit.Profiles[Player].Data.Inventory

        if Inventory[Category] then
            if add then
                if not self:_search(Player, Category, Item) then
                    table.insert(Inventory[Category], Item)
                    self.Client.UpdateInventory:Fire(Player, Category, Item, add)
                    return true
                end
            else
                if self:_search(Player, Category, Item) then
                    table.remove(Inventory[Category], table.find(Inventory[Category], Item))
                    self.Client.UpdateInventory:Fire(Player, Category, Item, add)
                    return true
                end
            end
        end
    end
end

function InventoryService:_search(Player: Player, Category: string, Item: string)

    repeat task.wait() until Player:GetAttribute("Loaded")

    if Knit.Profiles[Player] then
        local Inventory = Knit.Profiles[Player].Data.Inventory

        if Inventory[Category] then
            if table.find(Inventory[Category], Item) then
                return true
            end
        end

        return false
    end
end

function InventoryService:_equip(Player: Player, Category: string, Item: string, equip: boolean)

    repeat task.wait() until Player:GetAttribute("Loaded")

    local function EquipNametag(Player, Item)
		OverheadService:StopGradient(Player)
		OverheadService:CreateGradient(Player, Item)
	end

    if Knit.Profiles[Player] then
        local Inventory = Knit.Profiles[Player].Data.Inventory

        if equip then
            if self:_search(Player, Category, Item) then
                Inventory.Equipped[Category] = Item

                if tostring(Category) == "Nametags" then
                    EquipNametag(Player, Item)
                end
            end
        else
            -- unequip logic here
        end
    end
end

function InventoryService:_getEquipped(Player: Player, Category: string)

    repeat task.wait() until Player:GetAttribute("Loaded")

    if Knit.Profiles[Player] then
        local Inventory = Knit.Profiles[Player].Data.Inventory

        if Inventory.Equipped[Category] then
            return Inventory.Equipped[Category]
        end

        return nil
    end
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
