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

local AnimNation = require(Knit.Modules.AnimNation) -- @module AnimNation

-- Create Controller
local KitchenController = Knit.CreateController { Name = "KitchenController" }

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local FridgeUI = GochiUI:WaitForChild("Fridge")

local TaskUI = GochiUI:WaitForChild("Task")

local KitchenService
local TaskTrove = Trove.new()

local AnimationService
local UIController

-- Task Handlers
KitchenController.TaskHandlers = {}

-- Handle fridge task: getIngredient
KitchenController.TaskHandlers.Fridge = {
	getIngredient = function(self, task, model)
		print("Handling fridge task:", task.TaskID)

		local promptHolder = model:FindFirstChild("main")
		if not promptHolder then
			warn("Missing main in model:", model.Name)
			return
		end

		local prompt = promptHolder['main door']:FindFirstChild("ProximityPrompt")
		print(prompt)
		if not prompt then
			warn("Missing ProximityPrompt in main door")
			return
		end

		local notif = self:CreateTaskNotif(`Go to the fridge and get <b>{task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			AnimationService:PlayAnimation("Fridge", "Open", model)
			prompt.Enabled = false

			local button = FridgeUI.Content.Ingredients:FindFirstChild(task.Ingredient)

			if button then
				button.UIGradient.Enabled = true
				-- FridgeUI.Content.Ingredients.Visible = true
				-- UIController:Open(FridgeUI)

				button.Activated:Connect(function()
					UIController:Close(FridgeUI)
					FridgeUI.Content.Ingredients.Visible = false
					button.UIGradient.Enabled = false
					KitchenService:CompleteTask(task.TaskName, task.TaskID)
					self:HideTaskNotif()
					if conn then conn:Disconnect() end
				end)
			else
				self:HideTaskNotif()
				warn("Ingredient button not found in FridgeUI")
				if conn then conn:Disconnect() end
			end
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
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

        local notif = self:CreateTaskNotif("Go to the counter and get a plate.")
        if not notif then
            warn("Failed to create notification")
            return
        end
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
            self:HideTaskNotif()
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

function KitchenController:CreateTaskNotif(task)
	self:HideTaskNotif()

    TaskUI.Description.Text = task
    TaskUI.Visible = true
    AnimNation.target(TaskUI, {s = 10, d = 1}, {Position = UDim2.new(0.098, 0, 0.65, 0)})

    return true
end

function KitchenController:HideTaskNotif()
    AnimNation.target(TaskUI, {s = 10}, {Position = UDim2.new(-0.5, 0, 0.65, 0)}):AndThen(function()
        TaskUI.Description.Text = ""
        TaskUI.Visible = false
    end)
end

-- Knit Lifecycle
function KitchenController:KnitStart()
	KitchenService = Knit.GetService("KitchenService")
	AnimationService = Knit.GetService("AnimationService")
	UIController = Knit.GetController("UIController")

	KitchenService.Tasks:Connect(function(task)
		self:HandleTask(task)
	end)

    KitchenService.QueueNotification:Connect(function(task)
        self:CreateTaskNotif(task)
    end)
end

-- Return Controller to Knit
return KitchenController
