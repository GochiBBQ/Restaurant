--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Workspace = game:GetService("Workspace")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Classes = Knit.Classes
local Recipes = require(script.Recipes)

-- Data Structures
local TableMap = require(Knit.Structures.TableMap) -- @module TableMap
local HashSet = require(Knit.Structures.HashSet) -- @module HashSet

-- Create Service
local KitchenService = Knit.CreateService {
    Name = "KitchenService",
    Client = {
        Tasks = Knit.CreateSignal(),
        Games = Knit.CreateSignal(),

        Fridges = Knit.CreateSignal(),
        Stoves = Knit.CreateSignal(),
        RiceCookers = Knit.CreateSignal(),
        DrinkMachines = Knit.CreateSignal(),
        DrinkMixers = Knit.CreateSignal(),
        Fryers = Knit.CreateSignal(),
        WaffleMakers = Knit.CreateSignal(),
        TrashCans = Knit.CreateSignal(),
        PreparationAreas = Knit.CreateSignal(),

        Complete = Knit.CreateSignal(),
        Alerts = Knit.CreateSignal()
    }
}

-- Runtime State
local Cooking = Workspace:WaitForChild("Functionality"):WaitForChild("Cooking")
local NavigationService

-- Player Tasks
KitchenService.Tasks = TableMap.new() -- Player → Task
KitchenService.ActivePlayers = HashSet.new() -- Set of players with an active task

-- Server Functions
function KitchenService:KnitStart()
    NavigationService = Knit.GetService("NavigationService")
end

function KitchenService:_assignTask(Player, TaskType, TaskName, Model)
    if self.ActivePlayers:contains(Player) then
        warn(Player.Name .. " already has an active task.")
        return nil
    end

    local taskId = HttpService:GenerateGUID(false)
    local task = {
        TaskName = TaskName,
        TaskType = TaskType,
        TaskID = taskId,
        Complete = Signal.new(),
        Model = Model
    }

    self.Tasks:set(Player, task)
    self.ActivePlayers:add(Player)
    self.Client.Tasks:Fire(Player, task, Model)

    return task
end

function KitchenService:_completeTask(Player)
    local task = self.Tasks:get(Player)
    if task then
        task.Complete:Fire()
        task.Complete:Destroy()
        self.Tasks:remove(Player)
        self.ActivePlayers:remove(Player)
        print("Task completed for", Player.Name)
    else
        warn("No active task for", Player.Name)
    end
end

function KitchenService:SelectItem(Player: Player, Item: string)
    print("SelectItem", Player, Item)
    Recipes[Item](Player)
end

------------------------------------------------------------
-- Tasks
------------------------------------------------------------

function KitchenService:_getPlate(Player)
    return Promise.new(function(resolve, reject)
        local Plates = Cooking:WaitForChild("Plates")
        local children = Plates:GetChildren()
        if #children == 0 then return reject("No plates available") end

        local RandomPlate = children[math.random(1, #children)]
        local success = NavigationService:InitBeam(Player, RandomPlate)

        if not success then return reject("Failed to beam item") end

        local task = self:_assignTask(Player, "Plate", "getPlate", RandomPlate)
        if not task then return reject("Player already has a task") end

        task.Complete:Wait()
        resolve(true)
    end)
end

-- Client Functions
function KitchenService.Client:SelectReceipe(Player: Player, Stove: Instance, Item: string)
    Recipes[Item](Player, Stove)
end

function KitchenService.Client:CompleteTask(Player: Player, TaskName: string, TaskID: string)
    local task = self.Server.Tasks:get(Player)
    if task and task.TaskName == TaskName and task.TaskID == TaskID then
        self.Server:_completeTask(Player)
    else
        warn("Invalid or already completed task for", Player.Name)
    end
end

-- Return the service to Knit
return KitchenService
