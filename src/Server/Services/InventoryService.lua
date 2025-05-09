--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local NametagList: ModuleScript = require(Knit.Data.NametagList) -- @module NametagList
local ParticleList: ModuleScript = require(Knit.Data.ParticleList) -- @module ParticleList
local TableMap: ModuleScript = require(ServerScriptService.Structures.TableMap) --- @module TableMap

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
    Equipped = TableMap.new(), -- Player → { Particles }
}

-- Variables
local ParticlesFolder: Folder = Knit.Static:WaitForChild("Particles")

local PlayerStorage: Folder = workspace:WaitForChild("PlayerStorage")
local OverheadService
local RankService

-- Server Functions
function InventoryService:KnitStart()
    OverheadService = Knit.GetService("OverheadService")
    RankService = Knit.GetService("RankService")

    Players.PlayerAdded:Connect(function(Player)
        repeat task.wait() until Player:GetAttribute("Loaded")

        self.Equipped:set(Player, {
            Particles = nil,
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

            for _, particle in next, ParticleList do
                self:_update(Player, "Particles", particle.Name, true)
            end
        end

        Player.CharacterAdded:Connect(function()
            local particles = self:_getEquipped(Player, "Particles")

            if particles then
                self:_equip(Player, "Particles", particles, true)
            end
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

function InventoryService:_getEquipped(Player: Player, Category: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local Profile = Knit.Profiles[Player]
    if not Profile then return end

    return Profile.Data.Inventory.Equipped[Category]
end

function InventoryService:_unequipParticle(Player: Player)
    local equipped = self.Equipped:get(Player)
    if equipped and equipped.Particles then
        equipped.Particles:Destroy()
        equipped.Particles = nil
    end
end

function InventoryService:_equipParticle(Player: Player, Item: string)
    self:_unequipParticle(Player)

    local particleTemplate = ParticlesFolder:FindFirstChild(Item)
    if not particleTemplate then
        warn("Particle not found in ParticlesFolder:", Item)
        return
    end

    local attachment = particleTemplate:FindFirstChildOfClass("Attachment")
    if not attachment then
        warn("No Attachment found in particle item:", Item)
        return
    end

    local character = Player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local particle = attachment:Clone()
    particle.Parent = hrp

    local equipped = self.Equipped:get(Player)
    if not equipped then
        self.Equipped:set(Player, { Particles = particle })
    else
        equipped.Particles = particle
    end
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
            elseif Category == "Particles" then
                self:_equipParticle(Player, Item)
            end
        end
    else
        if Category == "Particles" then
            self:_unequipParticle(Player)
            Inventory.Equipped[Category] = nil
        end
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
