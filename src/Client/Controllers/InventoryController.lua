--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)

local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) -- @module AnimNation
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove
local ParticleEmitter: ModuleScript = require(Knit.Modules.ParticleEmitter) -- @module ParticleEmitter

local ParticleList: ModuleScript = require(Knit.Data.ParticleList) -- @module ParticleList
local NametagList: ModuleScript = require(Knit.Data.NametagList) -- @module NametagList
local RarityGradients: ModuleScript = require(Knit.Data.RarityGradients) -- @module RarityGradients

-- Create Knit Controller
local InventoryController = Knit.CreateController {
    Name = "InventoryController",
    Categories = {"Nametags", "Particles"},
    Inventory = { Nametags = {}, Particles = {} },
    Equipped = { 
       Text = { Nametags = nil, Particles = nil },
       Buttons = { Nametags = nil, Particles = nil },
    },
}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")

local InventoryUI: GuiObject = GochiUI:WaitForChild("Inventory")

local Buttons: GuiObject = InventoryUI.Buttons
local Pages: GuiObject = InventoryUI.Pages

local InventoryService, RankService
local UIController

-- Client Functions
function InventoryController:KnitStart()
    self._trove = Trove.new()

    InventoryService = Knit.GetService("InventoryService")
    RankService = Knit.GetService("RankService")
    UIController = Knit.GetController("UIController")

    for _, category in next, self.Categories do
        self:GetOwned(category)

        InventoryService:GetEquipped(category):andThen(function(equipped)
            self.Equipped.Text[category] = equipped
        end)
    end

    self:InitNavigation()

    task.delay(2, function()
        self:InitInventory()
    end)

    InventoryService.UpdateInventory:Connect(function(category: string, item: string, add: boolean)
        if add then
            table.insert(self.Inventory[category], item)
        else
            table.remove(self.Inventory[category], table.find(self.Inventory[category], item))
        end

        self:Refresh()
    end)

    self._trove:Connect(InventoryUI:GetPropertyChangedSignal("Visible"), function()
        if not InventoryUI.Visible then
            self:SetState(Buttons.List.Nametags, true)
            self:OpenPage(Pages.Nametags)
        end
    end)
end

function InventoryController:InitInventory()

    print("InitInventory")

    for _, category in next, self.Categories do
        local inventory = self.Inventory[category]

        if not inventory or #inventory == 0 then
            continue
        end

        for _, item in next, inventory do

            print(item, category)

            if not Pages[category]:FindFirstChild(item) then
                local template = InventoryUI.Template:Clone()
                template.Name = item
                template['Item Name'].Text = item
                template.Rarity.Text = (NametagList[item] and NametagList[item].Rarity) or (ParticleList[item] and ParticleList[item].Rarity) or "Common"
                self:CreateGradient(template.Rarity, (NametagList[item] and NametagList[item].Rarity) or (ParticleList[item] and ParticleList[item].Rarity) or "Common", true)

                if item == self.Equipped.Text[category] then
                    template.Equip.TextLabel.Text = "Unequip"
                else
                    template.Equip.TextLabel.Text = "Equip"
                end

                template.MouseEnter:Connect(function()
                    AnimNation.target(template, {s = 8}, {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.85
                    })
                end)

                template.MouseLeave:Connect(function()
                    AnimNation.target(template, {s = 8}, {
                        BackgroundColor3 = Color3.fromRGB(102, 102, 102),
                        BackgroundTransparency = 0.65
                    })
                end)

                if category == "Nametags" then
                    local nametag = template['Item Name']
                    
                    self:CreateGradient(nametag, item)
                elseif category == "Particles" then
                    local particle = template['Item Name']
                    
                    
                end

                template.Parent = Pages[category]
                template.Visible = true
            end
        end

        for _, button in pairs(Pages[category]:GetChildren()) do
            if button:IsA("Frame") then
                self._trove:Connect(button.Equip.Activated, function()
                    if button.Name == self.Equipped.Text[category] then
                        if category == "Nametags" then
                            InventoryService:Equip(category, "White", true):andThen(function()
                                self.Equipped.Buttons[category].Equip.TextLabel.Text = "Equip"

                                local white = Pages[category]:FindFirstChild("White")
                                if white then
                                    white.Equip.TextLabel.Text = "Unequip"
                                end

                                self.Equipped.Text[category] = "White"
                                self.Equipped.Buttons[category] = white
                            end)
                        else
                            InventoryService:Equip(category, button.Name, false):andThen(function()
                                self.Equipped.Buttons[category].Equip.TextLabel.Text = "Equip"

                                self.Equipped.Buttons[category] = nil
                                self.Equipped.Text[category] = "None"
                            end)
                        end
                    else
                        InventoryService:Equip(category, button.Name, true):andThen(function()
                            if self.Equipped.Buttons[category] then
                                self.Equipped.Buttons[category].Equip.TextLabel.Text = "Equip"
                            end
                            button.Equip.TextLabel.Text = "Unequip"

                            self.Equipped.Buttons[category] = button
                            self.Equipped.Text[category] = button.Name
                        end)
                    end
                end)
            end
        end
    end
end

function InventoryController:Refresh()
    self:InitInventory()
end

function InventoryController:TableToClrSeq(table)
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

function InventoryController:CreateGradient(Nametag: TextLabel, Gradient: string, Rarity: boolean?)
    if Rarity then
        if RarityGradients[Gradient] then
            local gradient = Instance.new("UIGradient")
            gradient.Parent = Nametag

            local GradientTime
            if RarityGradients[Gradient]["Time"] then
                GradientTime = RarityGradients[Gradient]["Time"]
            else
                GradientTime = 4
            end

            local NumColors = #RarityGradients[Gradient]["Colors"]
            local ColorLength = 1 / NumColors

            RunService.RenderStepped:Connect(function()
                if InventoryUI.Visible then
                    local progress = (tick() % GradientTime) / GradientTime
                    local NewColors = {}
                    local WrapColor = false

                    for i = 1, NumColors + 1 do
                        local color = RarityGradients[Gradient]["Colors"][i] or RarityGradients[Gradient]["Colors"][i - NumColors]
                        local position = progress + (i - 1) / NumColors

                        if position > 1 then
                            position = position - 1
                        end
                        if position == 0 or position == 1 then
                            WrapColor = true
                        end

                        table.insert(NewColors, ColorSequenceKeypoint.new(position, color))
                    end

                    if not WrapColor then
                        local IndexProgress = ((1 - progress) / ColorLength) + 1
                        local Color1 = RarityGradients[Gradient]["Colors"][math.floor(IndexProgress)]
                        local Color2 = RarityGradients[Gradient]["Colors"][math.ceil(IndexProgress)]
                            or RarityGradients[Gradient]["Colors"][1]
                        local FinalColors = Color1:Lerp(Color2, IndexProgress % 1)

                        table.insert(NewColors, ColorSequenceKeypoint.new(0, FinalColors))
                        table.insert(NewColors, ColorSequenceKeypoint.new(1, FinalColors))
                    end

                    table.sort(NewColors, function(a, b)
                        return a.Time < b.Time
                    end)

                    gradient.Color = ColorSequence.new(NewColors)
                end
            end)
        end
    else
        if NametagList[Gradient] then
            local gradient = Instance.new("UIGradient")
            gradient.Parent = Nametag
    
            gradient.Name = Gradient
    
            if NametagList[Gradient]["Rotation"] then
                gradient.Rotation = NametagList[Gradient]["Rotation"]
            end
    
            local GradientTime
    
            if NametagList[Gradient]["Time"] then
                GradientTime = NametagList[Gradient]["Time"]
            else
                GradientTime = 4
            end
    
            local NumColors = #NametagList[Gradient]["Colors"]
            local ColorLength = 1 / NumColors
    
            RunService.RenderStepped:Connect(function()
                if InventoryUI.Visible then
                    local progress = (tick() % GradientTime) / GradientTime
                    local NewColors = {}
                    local WrapColor = false
    
                    for i = 1, NumColors + 1 do
                        local color = NametagList[Gradient]["Colors"][i] or NametagList[Gradient]["Colors"][i - NumColors]
                        local position = progress + (i - 1) / NumColors
    
                        if position > 1 then
                            position = position - 1
                        end
                        if position == 0 or position == 1 then
                            WrapColor = true
                        end
    
                        table.insert(NewColors, ColorSequenceKeypoint.new(position, color))
                    end
    
                    if not WrapColor then
                        local IndexProgress = ((1 - progress) / ColorLength) + 1
                        local Color1 = NametagList[Gradient]["Colors"][math.floor(IndexProgress)]
                        local Color2 = NametagList[Gradient]["Colors"][math.ceil(IndexProgress)]
                            or NametagList[Gradient]["Colors"][1]
                        local FinalColors = Color1:Lerp(Color2, IndexProgress % 1)
    
                        table.insert(NewColors, ColorSequenceKeypoint.new(0, FinalColors))
                        table.insert(NewColors, ColorSequenceKeypoint.new(1, FinalColors))
                    end
    
                    table.sort(NewColors, function(a, b)
                        return a.Time < b.Time
                    end)
    
                    gradient.Color = ColorSequence.new(NewColors)
                end
            end)
        end
    end
end

function InventoryController:GetOwned(Category: string)
	InventoryService:Get(Category):andThen(function(OwnedItems)
		if #OwnedItems > 0 then
			for _, Item in next, OwnedItems do
				if not table.find(self.Inventory[Category], Item) then
					table.insert(self.Inventory[Category], Item)
				end
			end
		end
	end)
end

function InventoryController:InitNavigation()
    for _, button in pairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            self._trove:Connect(button.MouseButton1Click, function()
                self:SetState(button, true)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    self._trove:Connect(InventoryUI.Close.MouseButton1Click, function()
        UIController:Close(InventoryUI)
    end)

    self._trove:Connect(InventoryUI:GetPropertyChangedSignal("Visible"), function()
        if not InventoryUI.Visible then
            self:SetState(Buttons.List.Nametags, true)
            self:OpenPage(Pages.Nametags)
        end
    end)
end

function InventoryController:SetState(Button: ImageButton, State: boolean)
    assert(Button:IsA("ImageButton"), "Button must be an ImageButton")
    assert(type(State) == "boolean", "State must be a boolean")

    if State then
        for _, button in pairs(Buttons.List:GetChildren()) do
            if button:IsA("ImageButton") then
                if button ~= Button then
                    AnimNation.target(button, {s = 10}, {ImageTransparency = 1})
                    AnimNation.target(button.TextLabel, {s = 10}, {
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    })
                end
                AnimNation.target(Button, {s = 10}, {ImageTransparency = 0})
                AnimNation.target(Button.TextLabel, {s = 10}, {
                    TextColor3 = Color3.fromRGB(30, 30, 30)
                })
            end
        end
    end
end

function InventoryController:OpenPage(Page: ScrollingFrame | Frame)
    assert(Page:IsA("ScrollingFrame") or Page:IsA("Frame"), "Page must be a Frame object")

    for _, page in ipairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") or page:IsA("Frame") then
            page.Visible = page == Page
        end
    end
end

-- Return Controller to Knit.
return InventoryController
