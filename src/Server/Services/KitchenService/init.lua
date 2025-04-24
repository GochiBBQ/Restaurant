--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Classes = Knit.Classes
local Recipes = require(script.Recipes) --- @module Recipes
local Minigames = require(script.Minigames) --- @module Minigames

-- Data Structures
local TableMap = require(ServerScriptService.Structures.TableMap) -- @module TableMap
local HashSet = require(ServerScriptService.Structures.HashSet) -- @module HashSet
local Queue = require(ServerScriptService.Structures.Queue) -- @module Queue

-- Create Service
local KitchenService = Knit.CreateService {
	Name = "KitchenService",
	TaskQueues = {}, -- [Player] = { {TaskType=..., TaskName=..., Model=...}, ... }
	Client = {
		Tasks = Knit.CreateSignal(),
		Games = Knit.CreateSignal(),
		MinigameComplete = Knit.CreateSignal(),
        QueueNotification = Knit.CreateSignal(),

		Complete = Knit.CreateSignal(),
		Alerts = Knit.CreateSignal()
	}
}

-- Variables
local Cooking = Workspace:WaitForChild("Functionality"):WaitForChild("Cooking")
local KitchenModels = ServerStorage:WaitForChild("KitchenModels")

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
	Recipes[Item](Player)
end

function KitchenService:_assignToolToCharacter(Player: Player, Item: string)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Tool = ServerStorage:WaitForChild("Food"):FindFirstChild(Item)
	if Tool then
		local Clone = Tool:Clone()
		Clone.Parent = Character
	else
		warn("Tool not found in ServerStorage:", Item)
	end
end

function KitchenService:_removeToolFromCharacter(Player: Player, Item: string)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Tool = Character:FindFirstChild(Item)
	if Tool then
		Tool:Destroy()
	else
		warn("Tool not found in character:", Item)
	end
end

------------------------------------------------------------
-- Tasks
------------------------------------------------------------

function KitchenService:_getPlate(Player: Player)
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

function KitchenService:_getBowl(Player: Player)
	return Promise.new(function(resolve, reject)
		local Bowls = Cooking:WaitForChild("Bowls")
		local children = Bowls:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available bowls. Adding player to queue.")
			local queue = self.ModelQueues:get("Bowl") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Bowl", queue)
			self.Client.QueueNotification:Fire(Player, "All bowls are busy. You've been queued.")
			return
		end

		local selectedBowl = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedBowl)
		if not success then return reject("Failed to beam to bowl") end

		local task = self:_assignTask(Player, "Bowl", "getBowl", selectedBowl)
		if not task then return reject("Player already has a task or bowl in use") end

		task.Complete:Wait()
		resolve(true)
	end)
end

function KitchenService:_cookRice(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local RiceCookers = Cooking:WaitForChild("Rice Cookers")
		local children = RiceCookers:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available rice cookers. Adding player to queue.")
			local queue = self.ModelQueues:get("RiceCooker") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("RiceCooker", queue)
			self.Client.QueueNotification:Fire(Player, "All rice cookers are busy. You've been queued.")
			return
		end

		local selectedRiceCooker = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedRiceCooker)
		if not success then return reject("Failed to beam to rice cooker") end

		local task = self:_assignTask(Player, "RiceCooker", "cookRice", selectedRiceCooker, Item)
		if not task then return reject("Player already has a task or rice cooker in use") end

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

function KitchenService:_getStorageItem(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local Storage = Cooking:WaitForChild("Storage")
		local children = Storage:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available storage. Adding player to queue.")
			local queue = self.ModelQueues:get("Storage") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Storage", queue)
			self.Client.QueueNotification:Fire(Player, "All storage areas are busy. You've been queued.")
			return
		end

		local selectedStorage = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedStorage)
		if not success then return reject("Failed to beam to storage") end

		local task = self:_assignTask(Player, "Storage", "getItem", selectedStorage, Item)
		if not task then return reject("Player already has a task or storage in use") end
		task.Complete:Wait()
		resolve(true)
	end)
end

function KitchenService:_rollItem(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local PreparationAreas = Cooking:WaitForChild("Preparation Areas")
		local children = PreparationAreas:GetChildren()
		local available = {}
		
		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if available == 0 then
			print("No available preparation areas. Adding player to queue.")
			local queue = self.ModelQueues:get("Roller Board") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Roller Board", queue)
			self.Client.QueueNotification:Fire(Player, "All preparation areas are busy. You've been queued.")
			return
		end

		local selectedArea = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedArea)
		if not success then return reject("Failed to beam to preparation area") end

		local task = self:_assignTask(Player, "PreparationArea", "rollItem", selectedArea, Item)
		if not task then return reject("Player already has a task or preparation area in use") end
		task.Complete:Wait()
		resolve(true)
	end)
end

function KitchenService:_fryItem(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local Stoves = Cooking:WaitForChild("Stoves")
		local children = Stoves:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available stoves. Adding player to queue.")
			local queue = self.ModelQueues:get("Stove") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Stove", queue)
			self.Client.QueueNotification:Fire(Player, "All stoves are busy. You've been queued.")
			return
		end

		local selectedStove = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedStove)
		if not success then return reject("Failed to beam to stove") end

		local task = self:_assignTask(Player, "Stove", "fryItem", selectedStove, Item)
		if not task then return reject("Player already has a task or stove in use") end

		task.Complete:Wait()
		resolve(true)
	end)
end

function KitchenService:_boilItem(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local Stoves = Cooking:WaitForChild("Stoves")
		local children = Stoves:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available stoves. Adding player to queue.")
			local queue = self.ModelQueues:get("Stove") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Stove", queue)
			self.Client.QueueNotification:Fire(Player, "All stoves are busy. You've been queued.")
			return
		end

		local selectedStove = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedStove)
		if not success then return reject("Failed to beam to stove") end

		local task = self:_assignTask(Player, "Stove", "boilItem", selectedStove, Item)
		if not task then return reject("Player already has a task or stove in use") end

		task.Complete:Wait()
		resolve(true)
	end)
	
end

function KitchenService:_deepFryItem(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local Fryers = Cooking:WaitForChild("Fryers")
		local children = Fryers:GetChildren()
		local available = {}

		for _, model in ipairs(children) do
			if not self.ModelLocks:contains(model) then
				table.insert(available, model)
			end
		end

		if #available == 0 then
			print("No available fryers. Adding player to queue.")
			local queue = self.ModelQueues:get("Fryer") or Queue.new()
			queue:push(Player)
			self.ModelQueues:set("Fryer", queue)
			self.Client.QueueNotification:Fire(Player, "All fryers are busy. You've been queued.")
			return
		end

		local selectedFryer = available[math.random(1, #available)]
		local success = NavigationService:InitBeam(Player, selectedFryer)
		if not success then return reject("Failed to beam to fryer") end

		local task = self:_assignTask(Player, "Fryer", "deepFryItem", selectedFryer, Item)
		if not task then return reject("Player already has a task or fryer in use") end

		for _, part in pairs(selectedFryer.fryer:GetChildren()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		task.Complete:Wait()
		for _, part in pairs(selectedFryer.fryer:GetChildren()) do
			if part:IsA("BasePart") then
				part.Transparency = part:GetAttribute("Transparency")
			end
		end
		resolve(true)
	end)
end

function KitchenService:_createModel(Player: Player, Model: string)

	print("Creating model:", Model)

	if Model == "Frying Pan" then
		local FryingPan = KitchenModels.Models:WaitForChild("Frying Pan"):Clone()
		FryingPan.Parent = Player.Character

		print("Frying Pan created:", FryingPan.Name)
		print("Frying Pan parent:", FryingPan.Parent.Name)

		local RightHand = Player.Character:WaitForChild("RightHand")

		local Motor6D = KitchenModels.Motors:WaitForChild("FryingPanMotor"):Clone()
		Motor6D.Part0 = RightHand
		Motor6D.Part1 = FryingPan
		Motor6D.Parent = RightHand
	elseif Model == "Fryer" then
		local Fryer = KitchenModels.Models:WaitForChild("Fryer"):Clone()
		Fryer.Parent = Player.Character

		local LeftHand = Player.Character:WaitForChild("LeftHand")

		local Motor6D = KitchenModels.Motors:WaitForChild("FryerMotor"):Clone()
		Motor6D.Part0 = LeftHand
		Motor6D.Part1 = Fryer.Handle
		Motor6D.Parent = LeftHand
	elseif Model == "Hotdog" then
		local Hotdog = KitchenModels.Models:WaitForChild("Hotdog"):Clone()
		Hotdog.Parent = Player.Character

		local RightHand = Player.Character:WaitForChild("RightHand")

		local Motor6D = KitchenModels.Motors:WaitForChild("HotdogMotor"):Clone()
		Motor6D.Part0 = RightHand
		Motor6D.Part1 = Hotdog.stick
		Motor6D.Parent = RightHand
	elseif Model == "Pot" then
		local Pot = KitchenModels.Models:WaitForChild("Pot"):Clone()
		local Ladle = KitchenModels.Models:WaitForChild("Ladle"):Clone()
		Pot.Parent = Player.Character
		Ladle.Parent = Player.Character

		local RightHand = Player.Character:WaitForChild("RightHand")
		local LeftHand = Player.Character:WaitForChild("LeftHand")

		local PotMotor6D = KitchenModels.Motors:WaitForChild("PotMotor"):Clone()
		PotMotor6D.Part0 = RightHand
		PotMotor6D.Part1 = Pot.default
		PotMotor6D.Parent = RightHand

		local LadleMotor6D = KitchenModels.Motors:WaitForChild("LadleMotor"):Clone()
		LadleMotor6D.Part0 = LeftHand
		LadleMotor6D.Part1 = Ladle
		LadleMotor6D.Parent = LeftHand

	else
		warn("Model not recognized:", Model)
	end
end

function KitchenService:_removeModel(Player: Player, Model: string)
	local Character = Player.Character or Player.CharacterAdded:Wait()

	if Model == "Frying Pan" then
		local FryingPan = Character:FindFirstChild("Frying Pan")
		if FryingPan then
			FryingPan:Destroy()
		end

		local Motor6D = Character:WaitForChild("RightHand"):FindFirstChild("FryingPanMotor")
		if Motor6D then
			Motor6D:Destroy()
		end
	elseif Model == "Fryer" then
		local Fryer = Character:FindFirstChild("Fryer")
		if Fryer then
			Fryer:Destroy()
		end

		local Motor6D = Character:WaitForChild("LeftHand"):FindFirstChild("FryerMotor")
		if Motor6D then
			Motor6D:Destroy()
		end
	elseif Model == "Hotdog" then
		local Hotdog = Character:FindFirstChild("Hotdog")
		if Hotdog then
			Hotdog:Destroy()
		end

		local Motor6D = Character:WaitForChild("RightHand"):FindFirstChild("HotdogMotor")
		if Motor6D then
			Motor6D:Destroy()
		end
	elseif Model == "Pot" then
		local Pot = Character:FindFirstChild("Pot")
		if Pot then
			Pot:Destroy()
		end

		local Ladle = Character:FindFirstChild("Ladle")
		if Ladle then
			Ladle:Destroy()
		end

		local PotMotor6D = Character:WaitForChild("RightHand"):FindFirstChild("PotMotor")
		if PotMotor6D then
			PotMotor6D:Destroy()
		end

		local LadleMotor6D = Character:WaitForChild("LeftHand"):FindFirstChild("LadleMotor")
		if LadleMotor6D then
			LadleMotor6D:Destroy()
		end
	else
		warn("Model not recognized:", Model)
	end
end

function KitchenService:_submitItem(Player: Player, Item: string)
	return Promise.new(function(resolve, reject)
		local finishOrder = Cooking:WaitForChild("FinishOrder")

		local success = NavigationService:InitBeam(Player, finishOrder)
		if not success then return reject("Failed to beam to finish order") end

		local task = self:_assignTask(Player, "FinishOrder", "submitItem", finishOrder, Item)
		if not task then return reject("Player already has a task in progress") end

		self:_assignToolToCharacter(Player, Item)

		task.Complete:Wait()
		self:_removeToolFromCharacter(Player, Item)
		resolve(true)
	end)
end

-- Client Functions
function KitchenService.Client:AssignTool(Player: Player, Item: string)
	self.Server:_assignToolToCharacter(Player, Item)
end

function KitchenService.Client:RemoveTool(Player: Player, Item: string)
	self.Server:_removeToolFromCharacter(Player, Item)
end

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

function KitchenService.Client:CreateModel(Player: Player, Model: string)
	self.Server:_createModel(Player, Model)
end

function KitchenService.Client:RemoveModel(Player: Player, Model: string)
	self.Server:_removeModel(Player, Model)	
end

function KitchenService.Client:StartMinigame(Player: Player)
	return Minigames:startRandomMinigame(Player)
end

function KitchenService.Client:FinishMinigame(Player: Player)
	Minigames:Complete(Player)
end

-- Return the service to Knit
return KitchenService
