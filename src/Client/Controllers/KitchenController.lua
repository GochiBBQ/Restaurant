--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) -- @module Knit
local Trove = require(ReplicatedStorage.Packages.Trove) -- @module Trove

local AnimNation = require(Knit.Modules.AnimNation) -- @module AnimNation

-- Create Controller
local KitchenController = Knit.CreateController { Name = "KitchenController" }

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local FridgeUI = GochiUI:WaitForChild("Fridge")
local StorageUI = GochiUI:WaitForChild("Storage")

local TaskUI = GochiUI:WaitForChild("Task")

local KitchenService
local TaskTrove = Trove.new()

local AnimationService
local UIController

-- Task Handlers
KitchenController.TaskHandlers = {}

-- Handle finishing order task: finishOrder
KitchenController.TaskHandlers.FinishOrder = {
	submitItem = function(self, Task, model)
		local ProximityPrompt = model:FindFirstChild("ProximityPrompt")
		if not ProximityPrompt then
			warn("Missing ProximityPrompt in model:", model.Name)
			return
		end

		local notif = self:CreateTaskNotif("Go to the counter and submit your order.")
		if not notif then
			warn("Failed to create notification")
			return
		end
		ProximityPrompt.Enabled = true

		local conn
		conn = ProximityPrompt.Triggered:Connect(function()
			ProximityPrompt.Enabled = false
			self:HideTaskNotif()
			KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
		end)
		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			ProximityPrompt.Enabled = false
		end)
		
	end
}

-- Handle fryer tasks
KitchenController.TaskHandlers.Fryer = {
	deepFryItem = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the fryer and deep fry <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.Enabled = true
 
		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()
			KitchenService:CreateModel("Fryer")
			KitchenService:CreateModel("Hotdog")
			AnimationService:PlayAnimation("Fryer", "DeepFry", model)
			task.delay(4, function()
				KitchenService:RemoveModel("Fryer")
				KitchenService:RemoveModel("Hotdog")
				KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
			end)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
		
	end
}

-- Handle stove task: fryItem
KitchenController.TaskHandlers.Stove = {
	fryItem = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the stove and fry <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()
			KitchenService:CreateModel("Frying Pan")
			AnimationService:PlayAnimation("Stove", "Fry", model)
			task.delay(4, function()
				KitchenService:RemoveModel("Frying Pan")
				KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
			end)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end
}

KitchenController.TaskHandlers.Storage = {
	getItem = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the storage and get <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false

			local button = StorageUI.Content.Ingredients:FindFirstChild(Task.Ingredient)

			if button then
				button.UIGradient.Enabled = true
				StorageUI.Content.Ingredients.Visible = true
				UIController:Open(StorageUI)

				local buttonConn
				buttonConn = button.Activated:Connect(function()
					UIController:Close(StorageUI)
					StorageUI.Content.Ingredients.Visible = false
					button.UIGradient.Enabled = false
					KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
					self:HideTaskNotif()
					if conn then conn:Disconnect() end
					if buttonConn then buttonConn:Disconnect() end
				end)

				TaskTrove:Add(buttonConn)
			else
				self:HideTaskNotif()
				warn("Ingredient button not found in StorageUI")
				if conn then conn:Disconnect() end
			end
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end
}

-- Handle fridge task: getIngredient
KitchenController.TaskHandlers.Fridge = {
	getIngredient = function(self, Task, model)
		local promptHolder = model:FindFirstChild("main")
		if not promptHolder then
			warn("Missing main in model:", model.Name)
			return
		end

		local prompt = promptHolder['main door']:FindFirstChild("ProximityPrompt")
		if not prompt then
			warn("Missing ProximityPrompt in main door")
			return
		end

		local notif = self:CreateTaskNotif(`Go to the fridge and get <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			AnimationService:PlayAnimation("Fridge", "Open", model)
			prompt.Enabled = false

			task.delay(1.2, function()
				AnimationService:PlayAnimation("Fridge", "Idle", model, true)
			end)

			local button = FridgeUI.Content.Ingredients:FindFirstChild(Task.Ingredient)

			if button then
				button.UIGradient.Enabled = true
				FridgeUI.Content.Ingredients.Visible = true
				UIController:Open(FridgeUI)

				local buttonConn
				buttonConn = button.Activated:Connect(function()
					UIController:Close(FridgeUI)
					FridgeUI.Content.Ingredients.Visible = false
					button.UIGradient.Enabled = false
					AnimationService:StopAnimation()
					AnimationService:PlayAnimation("Fridge", "Close", model)
					KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
					self:HideTaskNotif()
					if conn then conn:Disconnect() end
					if buttonConn then buttonConn:Disconnect() end
				end)

				TaskTrove:Add(buttonConn)
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

-- Handle preparation area task: rollItem
KitchenController.TaskHandlers.PreparationArea = {
	rollItem = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the preparation area and roll <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()
			AnimationService:PlayAnimation("Preparation", "Roll", model)
			task.delay(1.33, function()
				KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
			end)
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
