--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService: TweenService = game:GetService("TweenService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove)
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) --- @module AnimNation

local CrateList: ModuleScript = require(Knit.Data.CrateList) -- @module CrateList
local RarityGradients: ModuleScript = require(Knit.Data.RarityGradients) -- @module RarityGradients

-- Create Knit Controller
local StoreController = Knit.CreateController {
    Name = "StoreController",
    Selected = "Featured"
}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")
local StoreUI: GuiObject = GochiUI:WaitForChild("Store")

local Buttons: GuiObject = StoreUI.Buttons
local Pages: GuiObject = StoreUI.Pages

local StoreService
local UIController
local _trove = Trove.new()

-- Client Functions
function StoreController:KnitStart()
    StoreService = Knit.GetService("StoreService")
    UIController = Knit.GetController("UIController")

    for _, button in ipairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            _trove:Connect(button.MouseButton1Click, function()
                if self.Selected ~= button.Name then
                    Pages[self.Selected].Visible = false
                    self:SetState(Buttons.List[self.Selected], true)

                    self.Selected = button.Name
                    Pages[self.Selected].Visible = true
                    self:SetState(button, false)
                end

                self:SetState(button, true)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    _trove:Connect(StoreUI.Close.MouseButton1Click, function()
        UIController:Close(StoreUI)
    end)

    _trove:Connect(StoreUI:GetPropertyChangedSignal("Visible"), function()
        if not StoreUI.Visible then
            self:SetState(Buttons.List.Featured, true)
            self:OpenPage(Pages.Featured)
            self.Selected = "Featured"
        end
    end)

    for _, page in ipairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") then
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("Frame") then
                    _trove:Connect(child.MouseEnter, function()
                        AnimNation.target(child, {s = 8}, {
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.85
                        })
                    end)

                    _trove:Connect(child.MouseLeave, function()
                        AnimNation.target(child, {s = 8}, {
                            BackgroundColor3 = Color3.fromRGB(102, 102, 102),
                            BackgroundTransparency = 0.65
                        })
                    end)

                    _trove:Connect(child.Purchase.Activated, function()
                        if page.Name == "Crates" then
                            local crateName = child.Name

                            StoreService:PurchaseCrate(crateName):andThen(function(result)
                                if result then
                                    local spinnerItems = result.SpinnerList
                                    local reward = result.Reward

                                    UIController:Close(StoreUI)
                                    self:StartCrateSpin(spinnerItems, reward)
                                end
                            end)
                        end
                    end)
                end
            end
        end
    end
end

function StoreController:TableToClrSeq(table)
	local timePositions = {}
	local colors = {}

	local j = 0
	local decimal = (10 / (#table - 1)) / 10
	for i = #table, 1, -1 do
		local timePos = if i == #table then 0 else decimal * j
		timePositions[j + 1] = timePos
		j += 1
	end

	for i = 1, #table do
		local color = table[i]
		colors[i] = ColorSequenceKeypoint.new(timePositions[i], color)
	end

	return ColorSequence.new(colors)
end

function StoreController:StartCrateSpin(items, finalReward)
    -- Clean up any previous spin connections
    if self._currentSpinConnection then
        self._currentSpinConnection:Disconnect()
        self._currentSpinConnection = nil
    end

    if self._currentTween then
        self._currentTween:Cancel()
        self._currentTween = nil
    end

    GochiUI.Spin.Description.Visible = false
    local spinnerFrame = GochiUI.Spin.Main
    local itemTemplate = spinnerFrame.Template
    local uiListLayout = spinnerFrame.UIListLayout

    -- Clear previous items (keeping only template)
    for _, child in ipairs(spinnerFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "Template" then
            child:Destroy()
        end
    end

    -- Make template invisible during setup
    itemTemplate.Visible = false

    -- Clone base items
    local allItems = {}
    for i, reward in ipairs(items) do
        local newItem = itemTemplate:Clone()
        newItem.Name = string.format("%02d_%s", i, reward.Name)
        newItem["Item Name"].Text = reward.Name
        newItem["Item Type"].Text = reward.Type
        newItem["Rarity"].Text = reward.Rarity
        newItem["Rarity"].UIGradient.Color = self:TableToClrSeq(RarityGradients[reward.Rarity].Colors)
        newItem.Normal.Visible = true
        newItem.Selected.Visible = false
        newItem.Visible = true
        newItem.Parent = spinnerFrame
        table.insert(allItems, newItem)
    end

    -- Clone items to create looping effect (3 full loops)
    for _ = 1, 3 do
        for _, original in ipairs(allItems) do
            local clone = original:Clone()
            clone.Name = "Clone_" .. original.Name
            clone.Parent = spinnerFrame
        end
    end

    -- Force layout recalculation
    spinnerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    for _ = 1, 3 do game:GetService("RunService").Heartbeat:Wait() end

    -- Calculate dimensions
    local firstItem = spinnerFrame:FindFirstChildWhichIsA("Frame")
    if not firstItem then warn("No items created!"); return end
    
    local itemWidth = firstItem.AbsoluteSize.X + uiListLayout.Padding.Offset
    local totalItems = #spinnerFrame:GetChildren() - 1 -- exclude template
    local totalWidth = itemWidth * totalItems
    spinnerFrame.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
    
    -- Wait for final layout
    for _ = 1, 3 do game:GetService("RunService").Heartbeat:Wait() end

    -- Find all instances of the reward (we want the last clone)
    local rewardFrames = {}
    for _, child in ipairs(spinnerFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "Template" and child:FindFirstChild("Item Name") 
           and child["Item Name"].Text == finalReward.Name then
            table.insert(rewardFrames, child)
        end
    end

    if #rewardFrames == 0 then
        warn("Final reward frame not found for: "..finalReward.Name)
        return
    end

    -- We want to stop at the last clone (approximately 2/3 through the total width)
    local finalFrame = rewardFrames[#rewardFrames]
    local targetPosition = (finalFrame.AbsolutePosition.X - spinnerFrame.AbsolutePosition.X) + 
                          (finalFrame.AbsoluteSize.X/2) - 
                          (spinnerFrame.AbsoluteSize.X/2)

    -- Ensure position is within bounds
    targetPosition = math.clamp(targetPosition, 0, totalWidth - spinnerFrame.AbsoluteSize.X)

    -- Start spinning from left
    spinnerFrame.CanvasPosition = Vector2.new(0, 0)
    UIController:Open(GochiUI.Spin)
    task.wait(0.1) -- Small delay before starting

    -- Create the tween
    local startTime = tick()
    local tweenInfo = TweenInfo.new(
        4, -- Full 4 second duration
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(
        spinnerFrame,
        tweenInfo,
        {CanvasPosition = Vector2.new(targetPosition, 0)}
    )
    self._currentTween = tween

    -- Track when we pass the final frame to highlight it at the exact right moment
    local passedFinalFrame = false
    self._currentSpinConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not passedFinalFrame then
            local currentPos = spinnerFrame.CanvasPosition.X
            local framePos = finalFrame.AbsolutePosition.X - spinnerFrame.AbsolutePosition.X
            
            -- Check if we've passed the final frame
            if currentPos + spinnerFrame.AbsoluteSize.X >= framePos + finalFrame.AbsoluteSize.X then
                passedFinalFrame = true
                -- Highlight the final frame
                for _, child in ipairs(spinnerFrame:GetChildren()) do
                    if child:IsA("Frame") and child:FindFirstChild("Selected") then
                        child.Selected.Visible = false
                    end
                end
                finalFrame.Selected.Visible = true
            end
        end
    end)

    tween:Play()
    
    tween.Completed:Connect(function()
        if self._currentSpinConnection then
            self._currentSpinConnection:Disconnect()
            self._currentSpinConnection = nil
        end
        
        -- Final position verification
        spinnerFrame.CanvasPosition = Vector2.new(targetPosition, 0)
        finalFrame.Selected.Visible = true

        GochiUI.Spin.Description.Visible = true
        GochiUI.Spin.Description.Description.Text = `You won an <b>{finalReward.Rarity} {finalReward.Name} {finalReward.Type:sub(1, -2)}</b>. Head on over to your inventory to equip your new collectible!`

        task.delay(2, function()
            UIController:Close(GochiUI.Spin)
            self._currentTween = nil
        end)
    end)
end

function StoreController:SetState(Button: ImageButton, State: boolean)
    assert(Button:IsA("ImageButton"), "Button must be an ImageButton")
    assert(type(State) == "boolean", "State must be a boolean")

    if State then
        for _, button in ipairs(Buttons.List:GetChildren()) do
            if button:IsA("ImageButton") then
                local isSelected = button == Button
                button.ImageTransparency = isSelected and 0 or 1
                button.TextLabel.TextColor3 = isSelected and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 255, 255)
            end
        end
    end
end

function StoreController:OpenPage(Page: ScrollingFrame | Frame)
    assert(Page:IsA("ScrollingFrame") or Page:IsA("Frame"), "Page must be a Frame object")

    for _, page in ipairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") or page:IsA("Frame") then
            page.Visible = false
        end
    end
    Page.Visible = true
end

-- Return Controller to Knit.
return StoreController
