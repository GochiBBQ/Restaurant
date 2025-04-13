--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) -- @module Knit
local Promise = require(Knit.Util.Promise) -- @module Promise
local Trove = require(ReplicatedStorage.Packages.Trove) -- @module Trove

-- Create Controller
local KitchenController = Knit.CreateController { Name = "KitchenController" }

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local FridgeUI = GochiUI:WaitForChild("Fridge")

local KitchenService
local TaskTrove = Trove.new()

-- Task Handlers
KitchenController.TaskHandlers = {}

-- Handle fridge task: getIngredient
KitchenController.TaskHandlers.Fridge = {
	getIngredient = function(self, task, model)
		print("Handling fridge task:", task.TaskID)

		-- TODO: Add fridge interaction logic here
		-- Simulated interaction delay
		Promise.delay(1):andThen(function()
			KitchenService:CompleteTask(task.TaskName, task.TaskID)
		end)
	end
}

-- Handle plate task: getPlate
KitchenController.TaskHandlers.Plate = {
	getPlate = function(self, task, model)
		print("Handling plate task:", task.TaskID)

		local promptHolder = model:FindFirstChild("PromptHolder")
		if not promptHolder then
			warn("Missing PromptHolder in model:", model.Name)
			return
		end

		local prompt = promptHolder:FindFirstChild("ProximityPrompt")
		if not prompt then
			warn("Missing ProximityPrompt in PromptHolder")
			return
		end

		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			KitchenService:CompleteTask(task.TaskName, task.TaskID)
			if conn then conn:Disconnect() end
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end
}

-- Dispatch tasks based on type and action
function KitchenController:HandleTask(task)
	TaskTrove:Clean()

	local action = task.TaskName
	local model = task.Model
	if not model then
		warn("Task model is missing")
		return
	end

	local taskType = task.TaskType
	local handlerGroup = self.TaskHandlers[taskType]

	if handlerGroup and handlerGroup[action] then
		handlerGroup[action](self, task, model)
	else
		warn("No handler found for", taskType, action)
	end
end

-- Knit Lifecycle
function KitchenController:KnitStart()
	KitchenService = Knit.GetService("KitchenService")

	KitchenService.Tasks:Connect(function(task)
		self:HandleTask(task)
	end)
end

-- Return Controller to Knit
return KitchenController
