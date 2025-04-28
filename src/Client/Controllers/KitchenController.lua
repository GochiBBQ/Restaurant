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

-- Minigame Elements
local MathUI = GochiUI:WaitForChild("CookingPuzzleMath")
local PuzzleUI = GochiUI:WaitForChild("CookingPuzzleSelection")

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

		ProximityPrompt.ObjectText = "Counter"
		ProximityPrompt.ActionText = "Submit Order"
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

KitchenController.TaskHandlers.IceMachine = {
	getIce = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the ice machine and get <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.ObjectText = "Ice Machine"
		prompt.ActionText = "Get Ice"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()
			KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
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

		prompt.ObjectText = "Fryer"
		prompt.ActionText = "Deep Fry"
		prompt.Enabled = true
 
		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						AnimationService:PlayAnimation("Fryer", "DeepFry", model, false)
						KitchenService:CreateModel("Fryer")
						KitchenService:CreateModel("Hotdog")

						local animationLength = Player:GetAttribute("AnimationLength")
						if not animationLength then
							Player:GetAttributeChangedSignal("AnimationLength"):Wait()
							animationLength = Player:GetAttribute("AnimationLength")
						end

						task.delay(animationLength, function()
							KitchenService:RemoveModel("Fryer")
							KitchenService:RemoveModel("Hotdog")
							KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
						end)
					end
				end)
				TaskTrove:Add(minigameConn)
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

		prompt.ObjectText = "Stove"
		prompt.ActionText = "Fry"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						AnimationService:PlayAnimation("Stove", "Fry", model)
						KitchenService:CreateModel("Frying Pan")

						local animationLength = Player:GetAttribute("AnimationLength")
						if not animationLength then
							Player:GetAttributeChangedSignal("AnimationLength"):Wait()
							animationLength = Player:GetAttribute("AnimationLength")
						end

						task.delay(animationLength, function()
							KitchenService:RemoveModel("Frying Pan")
							KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
						end)
					end
				end)
				TaskTrove:Add(minigameConn)
			end)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end,
	boilItem = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the stove and boil <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.ObjectText = "Stove"
		prompt.ActionText = "Boil"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						AnimationService:PlayAnimation("Stove", "Boil", model)
						KitchenService:CreateModel("Pot")
						
						local animationLength = Player:GetAttribute("AnimationLength")
						if not animationLength then
							Player:GetAttributeChangedSignal("AnimationLength"):Wait()
							animationLength = Player:GetAttribute("AnimationLength")
						end
						
						task.delay(animationLength, function()
							KitchenService:RemoveModel("Pot")
							KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
						end)
					end
				end)
				TaskTrove:Add(minigameConn)
			end)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end,
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

		local notif = self:CreateTaskNotif(`Go to storage and get <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.ObjectText = "Storage"
		prompt.ActionText = "Get Item"
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

		prompt.ObjectText = "Fridge"
		prompt.ActionText = "Get Ingredient"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			AnimationService:PlayAnimation("Fridge", "Open", model)
			prompt.Enabled = false

			task.delay(Player:GetAttribute("AnimationLength"), function()
				AnimationService:PlayAnimation("Fridge", "Idle", model, true)
			end)

			local button = FridgeUI.Content.Ingredients:FindFirstChild(Task.Ingredient)

			if button then
				button.UIGradient.Enabled = true
				FridgeUI.Content.Ingredients.Visible = true
				FridgeUI.Content.Drinks.Visible = false
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
	end,
	getDrinkIngredient = function(self, Task, model)
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

		prompt.ObjectText = "Fridge"
		prompt.ActionText = "Get Drink Ingredient"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			AnimationService:PlayAnimation("Fridge", "Open", model)
			prompt.Enabled = false

			task.delay(Player:GetAttribute("AnimationLength"), function()
				AnimationService:PlayAnimation("Fridge", "Idle", model, true)
			end)

			local button = FridgeUI.Content.Drinks:FindFirstChild(Task.Ingredient)

			if button then
				button.UIGradient.Enabled = true
				FridgeUI.Content.Ingredients.Visible = false
				FridgeUI.Content.Drinks.Visible = true
				UIController:Open(FridgeUI)

				local buttonConn
				buttonConn = button.Activated:Connect(function()
					UIController:Close(FridgeUI)
					FridgeUI.Content.Drinks.Visible = false
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
		prompt.ObjectText = "Preparation Area"
		prompt.ActionText = "Roll Item"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						AnimationService:PlayAnimation("Preparation", "Roll", model)
						task.delay(Player:GetAttribute("AnimationLength"), function()
							KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
						end)
					end
				end)
				TaskTrove:Add(minigameConn)
			end)			
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end
}

KitchenController.TaskHandlers.DrinkMachine = {
	getDrink = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the drink machine and get <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.ObjectText = "Drink Machine"
		prompt.ActionText = "Get Drink"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						AnimationService:PlayAnimation("DrinkMachine", "Pour", model)
						KitchenService:CreateModel("Cup")
						task.delay(Player:GetAttribute("AnimationLength"), function()
							KitchenService:RemoveModel("Cup")
							KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
						end)
					end
				end)
				TaskTrove:Add(minigameConn)
			end)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end
}

KitchenController.TaskHandlers.CoffeeMachine = {
	getCoffee = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the coffee machine and brew <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.ObjectText = "Coffee Machine"
		prompt.ActionText = "Get Coffee"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						AnimationService:PlayAnimation("DrinkMachine", "Pour", model)
						KitchenService:CreateModel("Cup")
						task.delay(Player:GetAttribute("AnimationLength"), function()
							KitchenService:RemoveModel("Cup")
							KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
						end)
					end
				end)
				TaskTrove:Add(minigameConn)
			end)
		end)

		TaskTrove:Add(conn)
		TaskTrove:Add(function()
			prompt.Enabled = false
		end)
	end
}

KitchenController.TaskHandlers.DrinkMixer = {
	mixDrink = function(self, Task, model)
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

		local notif = self:CreateTaskNotif(`Go to the drink mixer and mix <b>{Task.Ingredient}</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end

		prompt.ObjectText = "Drink Mixer"
		prompt.ActionText = "Mix Drink"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						KitchenService:CompleteTask(Task.TaskName, Task.TaskID)
					end
				end)
				TaskTrove:Add(minigameConn)
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
		prompt.ObjectText = "Plate"
		prompt.ActionText = "Get Plate"
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

KitchenController.TaskHandlers.Bowl = {
	getBowl = function(self, task, model)
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

		local notif = self:CreateTaskNotif("Go to the counter and get a bowl.")
		if not notif then
			warn("Failed to create notification")
			return
		end
		prompt.ObjectText = "Bowl"
		prompt.ActionText = "Get Bowl"
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

KitchenController.TaskHandlers.Cup = {
	getCup = function(self, task, model)
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

		local notif = self:CreateTaskNotif("Go to the counter and get a cup.")
		if not notif then
			warn("Failed to create notification")
			return
		end
		prompt.ObjectText = "Cup"
		prompt.ActionText = "Get Cup"
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

KitchenController.TaskHandlers.RiceCooker = {
	cookRice = function(self, task, model)
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

		local notif = self:CreateTaskNotif(`Go to the rice cooker and get <b>Rice</b>.`)
		if not notif then
			warn("Failed to create notification")
			return
		end
		prompt.ObjectText = "Rice Cooker"
		prompt.ActionText = "Cook Rice"
		prompt.Enabled = true

		local conn
		conn = prompt.Triggered:Connect(function()
			prompt.Enabled = false
			self:HideTaskNotif()

			KitchenService:StartMinigame():andThen(function()
				local minigameConn
				minigameConn = KitchenService.MinigameComplete:Connect(function(result, err)
					if err then
						warn("Minigame error:", err)
						return
					end
			
					if result then
						KitchenService:CompleteTask(task.TaskName, task.TaskID)
					end
				end)
				TaskTrove:Add(minigameConn)
			end)			
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

function KitchenController:Minigame(task)
	if task == "Math" then
		local operators = { "+", "-", "*", "/" }
		local operator = operators[math.random(1, #operators)]
		
		local num1, num2

		if operator == "+" then
			num1 = math.random(1, 50)
			num2 = math.random(1, 50)
		elseif operator == "-" then
			num1 = math.random(10, 50)
			num2 = math.random(1, num1)  -- ensures non-negative result
		elseif operator == "*" then
			num1 = math.random(1, 12)
			num2 = math.random(1, 12)
		elseif operator == "/" then
			num2 = math.random(1, 12)
			num1 = num2 * math.random(1, 12)  -- ensures integer division
		end

		local question = `What is {num1} {operator} {num2}?`
		local answer

		if operator == "+" then
			answer = tonumber(num1 + num2)
		elseif operator == "-" then
			answer = tonumber(num1 - num2)
		elseif operator == "*" then
			answer = tonumber(num1 * num2)
		elseif operator == "/" then
			answer = math.floor(num1 / num2)
		end

		MathUI.Content.Question.Text = question
		MathUI.Content.TypeHereBox.TextBox.Text = ""
		MathUI.Content.TypeHereBox.TextBox.PlaceholderText = "Type your answer here"
		UIController:Open(MathUI)

		local conn
		conn = MathUI.Content.SubmitButton.Activated:Connect(function()
				-- Check if the answer is correct
				if MathUI.Content.TypeHereBox.TextBox.Text == "" then
					MathUI.Content.TypeHereBox.TextBox.PlaceholderText = "Please enter a number"
					return
				end

				-- Convert the input to a number and compare with the answer
			local userInput = string.gsub(MathUI.Content.TypeHereBox.TextBox.Text, "^%s*(.-)%s*$", "%1")
			local userAnswer = tonumber(userInput)
			
				if userAnswer == answer then
					KitchenService:FinishMinigame()
					UIController:Close(MathUI)
					conn:Disconnect()
				else
					MathUI.Content.TypeHereBox.TextBox.Text = ""
					MathUI.Content.TypeHereBox.TextBox.PlaceholderText = "Try again!"
				end
		end)
		TaskTrove:Add(conn)
	elseif task == "PuzzleSelection" then
		-- Handle Puzzle Selection Minigame
	else
		warn("No minigame found")
	end
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

	KitchenService.Games:Connect(function(task)
		self:Minigame(task)
	end)
end

-- Return Controller to Knit
return KitchenController
