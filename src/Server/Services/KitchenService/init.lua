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
local Queue = require(Knit.Structures.Queue) -- @module Queue

-- Create Service
local KitchenService = Knit.CreateService {
	Name = "KitchenService",
	TaskQueues = {}, -- [Player] = { {TaskType=..., TaskName=..., Model=...}, ... }
	Client = {
		Tasks = Knit.CreateSignal(),
		Games = Knit.CreateSignal(),
        QueueNotification = Knit.CreateSignal(),

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
KitchenService.ModelLocks = TableMap.new() -- Model → Player
KitchenService.ModelQueues = TableMap.new() -- TaskType → Queue<Player>

-- Server Functions
function KitchenService:KnitStart()
	NavigationService = Knit.GetService("NavigationService")
end

function KitchenService:_assignTask(Player, TaskType, TaskName, Model, Ingredient: string?)
	-- If player is busy, queue the task
	if self.ActivePlayers:contains(Player) then
		self.TaskQueues[Player] = self.TaskQueues[Player] or {}
		table.insert(self.TaskQueues[Player], {TaskType = TaskType, TaskName = TaskName, Model = Model})
		self.Client.QueueNotification:Fire(Player, `You're busy. Queued task: {TaskName}`)
		return nil
	end

	-- If model is in use, reject
	if self.ModelLocks:contains(Model) then
		local lockedBy = self.ModelLocks:get(Model)
		warn(("Model %s is already in use by %s"):format(Model.Name, lockedBy.Name))
		return nil
	end

	local taskId = HttpService:GenerateGUID(false)
	local task = {
		TaskName = TaskName,
		TaskType = TaskType,
		TaskID = taskId,
		Complete = Signal.new(),
		Model = Model,
		Ingredient = Ingredient
	}

	self.Tasks:set(Player, task)
	self.ActivePlayers:add(Player)
	self.ModelLocks:set(Model, Player)
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

		local model = task.Model
		if self.ModelLocks:contains(model) then
			self.ModelLocks:remove(model)
		end

		print("Task completed for", Player.Name)

		-- Handle model-based queue
		local queue = self.ModelQueues:get(task.TaskType)
		if queue and not queue:isEmpty() then
			local nextPlayer = queue:pop()
			task.TaskType = task.TaskType -- trigger pattern match
			if task.TaskType == "Plate" then
				self:_getPlate(nextPlayer)
			end
			-- Extend with other task types as needed
		end

		-- Handle queued tasks for this player
		local personalQueue = self.TaskQueues[Player]
		if personalQueue and #personalQueue > 0 then
			local nextTask = table.remove(personalQueue, 1)
			task = self:_assignTask(Player, nextTask.TaskType, nextTask.TaskName, nextTask.Model)
			if task then
				task.Complete:Wait() -- start task immediately
			end
		end
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
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available plates. Adding player to model and task queues.")
		
			-- Model-based queue
			local queue = self.ModelQueues:get("Plate") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Plate", queue)
		
			-- Personal task queue
			self.TaskQueues[Player] = self.TaskQueues[Player] or {}
			table.insert(self.TaskQueues[Player], {
				TaskType = "Plate",
				TaskName = "getPlate",
				Model = nil -- Will be chosen when retried
			})
		
			self.Client.QueueNotification:Fire(Player, "There are no available plates. You have been added to the queue.")
			return
		end
		

		local RandomPlate = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, RandomPlate)
		if not success then return reject("Failed to beam item") end

		local task = self:_assignTask(Player, "Plate", "getPlate", RandomPlate)
		if not task then return reject("Player already has a task or model is in use") end

		task.Complete:Wait()
		resolve(true)
	end)
end

function KitchenService:_getFridgeIngredient(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local Fridges = Cooking:WaitForChild("Fridges")
		local children = Fridges:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available fridges. Adding player to queue.")
			local queue = self.ModelQueues:get("Fridge") or Queue.new()
			queue:push({Player = Player, Item = Item})
			self.ModelQueues:set("Fridge", queue)
			self.Client.QueueNotification:Fire(Player, "All fridges are busy. You've been queued.")
			return
		end

		local selectedFridge = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedFridge)
		if not success then return reject("Failed to beam to fridge") end

		local task = self:_assignTask(Player, "Fridge", "getIngredient", selectedFridge, Item)
		if not task then return reject("Player already has a task or fridge in use") end
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
