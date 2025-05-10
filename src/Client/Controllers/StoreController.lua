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
    -- Clean up previous spin
    if self._currentSpinConnection then
        self._currentSpinConnection:Disconnect()
        self._currentSpinConnection = nil
    end

    if self._currentTween then
        self._currentTween:Cancel()
        self._currentTween = nil
    end

    -- Reset UI state
    GochiUI.Spin.Description.Visible = false
    local spinnerFrame = GochiUI.Spin.Main
    local itemTemplate = spinnerFrame.Template
    local uiListLayout = spinnerFrame.UIListLayout

    -- Clear previous items (keeping template)
    for _, child in ipairs(spinnerFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= itemTemplate then
            child:Destroy()
        end
    end

    -- Store original template size and scale
    local originalSize = itemTemplate.Size
    local originalScale = itemTemplate.Size

    -- Make template invisible during setup (without reparenting)
    itemTemplate.Visible = false

    -- Clone base items with proper scaling
    local allItems = {}
    for i, reward in ipairs(items) do
        local newItem = itemTemplate:Clone()
        newItem.Name = string.format("%02d_%s", i, reward.Name)
        newItem.Size = originalSize -- Maintain original size
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

    -- Clone items to create looping effect (3 full loops) with consistent scaling
    for loopNum = 1, 3 do
        for _, original in ipairs(allItems) do
            local clone = original:Clone()
            clone.Name = string.format("L%d_%s", loopNum, original.Name)
            clone.Size = originalSize -- Maintain original size
            clone.Parent = spinnerFrame
        end
    end

    -- Force complete UI reset
    spinnerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    spinnerFrame.CanvasPosition = Vector2.new(0, 0)
    
    -- Wait for proper layout (using both Heartbeat and Stepped)
    for _ = 1, 5 do
        game:GetService("RunService").Heartbeat:Wait()
        game:GetService("RunService").Stepped:Wait()
    end

    -- Calculate dimensions with scaled items
    local firstItem = spinnerFrame:FindFirstChildWhichIsA("Frame")
    if not firstItem then
        warn("No items created in spinner!")
        return nil
    end
    
    local itemWidth = firstItem.AbsoluteSize.X + uiListLayout.Padding.Offset
    local totalItems = #spinnerFrame:GetChildren() - 1 -- exclude template
    local totalWidth = itemWidth * totalItems
    spinnerFrame.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
    
    -- Additional layout wait
    for _ = 1, 3 do
        game:GetService("RunService").Heartbeat:Wait()
    end

    -- Find reward instances (searching backwards)
    local rewardFrames = {}
    for i = #spinnerFrame:GetChildren(), 1, -1 do
        local child = spinnerFrame:GetChildren()[i]
        if child:IsA("Frame") and child:FindFirstChild("Item Name") and child["Item Name"].Text == finalReward.Name then
            table.insert(rewardFrames, child)
            if #rewardFrames >= 3 then break end
        end
    end

    if #rewardFrames == 0 then
        warn("Final reward frame not found for: "..finalReward.Name)
        return nil
    end

    -- Select the middle clone for consistent stopping
    local finalFrame = rewardFrames[math.floor(#rewardFrames/2)+1] or rewardFrames[1]
    local targetPosition = (finalFrame.AbsolutePosition.X - spinnerFrame.AbsolutePosition.X) + 
                         (finalFrame.AbsoluteSize.X/2) - 
                         (spinnerFrame.AbsoluteSize.X/2)

    -- Ensure position is within bounds
    targetPosition = math.clamp(targetPosition, 0, totalWidth - spinnerFrame.AbsoluteSize.X)

    -- Reset position and open UI
    spinnerFrame.CanvasPosition = Vector2.new(0, 0)
    UIController:Open(GochiUI.Spin)
    
    -- Extra delay to ensure UI is ready
    task.wait(0.2)

    -- Create tween with proper scaling
    local tweenInfo = TweenInfo.new(
        4, -- Full 4 second duration
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    self._currentTween = TweenService:Create(
        spinnerFrame,
        tweenInfo,
        {CanvasPosition = Vector2.new(targetPosition, 0)}
    )

    -- Highlight tracking
    local passedFinalFrame = false
    self._currentSpinConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not passedFinalFrame and finalFrame then
            local currentPos = spinnerFrame.CanvasPosition.X
            local framePos = finalFrame.AbsolutePosition.X - spinnerFrame.AbsolutePosition.X
            
            if currentPos + spinnerFrame.AbsoluteSize.X >= framePos + (finalFrame.AbsoluteSize.X * 0.8) then
                passedFinalFrame = true
                -- Clean highlight transition
                for _, child in ipairs(spinnerFrame:GetChildren()) do
                    if child:IsA("Frame") and child:FindFirstChild("Selected") then
                        child.Selected.Visible = false
                    end
                end
                finalFrame.Selected.Visible = true
            end
        end
    end)

    -- Start tween with completion handler
    self._currentTween:Play()
    
    self._currentTween.Completed:Connect(function()
        -- Final cleanup
        if self._currentSpinConnection then
            self._currentSpinConnection:Disconnect()
            self._currentSpinConnection = nil
        end

        -- Ensure final position
        spinnerFrame.CanvasPosition = Vector2.new(targetPosition, 0)
        if finalFrame then
            finalFrame.Selected.Visible = true
        end

        -- Show reward message
        GochiUI.Spin.Description.Visible = true
        GochiUI.Spin.Description.Description.Text = `You won an <b>{finalReward.Rarity} {finalReward.Name} {finalReward.Type:sub(1, -2)}</b>. Head on over to your inventory to equip your new collectible!`

        -- Close after delay
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
