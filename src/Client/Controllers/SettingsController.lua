--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation
local spr = require(Knit.Modules.spr)

-- Create Knit Controller
local SettingsController = Knit.CreateController {
    Name = "SettingsController",
    Selected = "Settings",
    Toggled = {}
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local SettingsUI = GochiUI:WaitForChild("Settings")

local DataService, GamepassService
local _trove = Trove.new()

local Toggles = {
    Selected = {
        Image = 'rbxassetid://101748321328124',
        Position = UDim2.fromScale(0.7, 0.5)
    },
    Deselected = {
        Image = 'rbxassetid://98655660944706',
        Position = UDim2.fromScale(0.3, 0.5)
    }
}

local Gamepasses = {
    ["Headless"] = { ID = 1002697699 },
    ["Korblox"] = { ID = 1004797619 },
    ["Walkspeed"] = { ID = 1003057662 },
    ["DisableUniform"] = { ID = 1003177642 },
}

-- Client Functions
function SettingsController:KnitStart()
    DataService = Knit.GetService("DataService")
    GamepassService = Knit.GetService("GamepassService")

    -- Load saved settings
    DataService:Get():andThen(function(Settings)
        for Setting, Toggle in pairs(Settings) do
            local Frame = SettingsUI:WaitForChild("Settings"):FindFirstChild(Setting)
            if Frame and Toggle then
                table.insert(self.Toggled, Frame)
                if Setting == "MuteMusic" then
                    TweenService:Create(workspace.Music, TweenInfo.new(1), {Volume = 0.5}):Play()
                end
            elseif Setting == "MuteMusic" then
                workspace.Music.Volume = 0
            end
        end
    end)

    _trove:Connect(DataService.UpdateSettings, function(Setting, Type)
        self:UpdateToggleUI(SettingsUI.Settings, Setting, Type)

        if Setting == "MuteMusic" then
            if Type then
                TweenService:Create(workspace.Music, TweenInfo.new(1), {Volume = 0.5}):Play()
            else
                workspace.Music.Volume = 0
            end
        end
    end)

    -- Load gamepasses
    GamepassService:Get():andThen(function(GamepassesOwned)
        for Gamepass, HasIt in pairs(GamepassesOwned) do
            local Frame = SettingsUI.Gamepasses:FindFirstChild(Gamepass)
            if Frame and HasIt then
                table.insert(self.Toggled, Frame)
            end
        end
    end)

    _trove:Connect(GamepassService.UpdateSettings, function(Gamepass, Type)
        self:UpdateToggleUI(SettingsUI.Gamepasses, Gamepass, Type)
    end)

    -- Tab button toggling
    for _, button in ipairs(SettingsUI.Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            _trove:Connect(button.MouseButton1Click, function()
                SettingsUI[self.Selected].Visible = false
                self:AnimateTab(SettingsUI.Buttons.List[self.Selected], true)

                self.Selected = button.Name
                SettingsUI[self.Selected].Visible = true
                self:AnimateTab(button, false)
            end)
        end
    end

    -- Delay toggle setup
    task.delay(5, function()
        self:InitSettings()
        self:InitGamepasses()
    end)
end

function SettingsController:UpdateToggleUI(container, name, state)
    local Frame = container:FindFirstChild(name)
    if not Frame then return end

    local ToggleObject = Frame.Switch.Toggle
    local Background = Frame.Switch.Background

    AnimNation.target(ToggleObject, {s = 10, d = 0.5}, {
        Position = (state and Toggles.Selected.Position) or Toggles.Deselected.Position
    })
    Background.Image = (state and Toggles.Selected.Image) or Toggles.Deselected.Image

    if state then
        table.insert(self.Toggled, Frame)
    else
        table.remove(self.Toggled, table.find(self.Toggled, Frame))
    end
end

function SettingsController:InitSettings()
    for _, Frame in ipairs(SettingsUI.Settings:GetChildren()) do
        if Frame:IsA("Frame") then
            local ToggleObject = Frame.Switch.Toggle
            local Background = Frame.Switch.Background

            local isToggled = table.find(self.Toggled, Frame)
            AnimNation.target(ToggleObject, {s = 7, d = 0.5}, {
                Position = (isToggled and Toggles.Selected.Position) or Toggles.Deselected.Position
            })
            Background.Image = (isToggled and Toggles.Selected.Image) or Toggles.Deselected.Image

            _trove:Connect(Frame.Switch.MouseButton1Click, function()
                local toggled = table.find(self.Toggled, Frame) ~= nil
                if toggled then
                    table.remove(self.Toggled, table.find(self.Toggled, Frame))
                else
                    table.insert(self.Toggled, Frame)
                end
                DataService:Update(Frame.Name, not toggled)
            end)
        end
    end
end

function SettingsController:InitGamepasses()
    for _, Frame in ipairs(SettingsUI.Gamepasses:GetChildren()) do
        if Frame:IsA("Frame") then
            local ToggleObject = Frame.Switch.Toggle
            local Background = Frame.Switch.Background

            local isToggled = table.find(self.Toggled, Frame)
            AnimNation.target(ToggleObject, {s = 5, d = 0.5}, {
                Position = (isToggled and Toggles.Selected.Position) or Toggles.Deselected.Position
            })
            Background.Image = (isToggled and Toggles.Selected.Image) or Toggles.Deselected.Image

            _trove:Connect(Frame.Switch.MouseButton1Click, function()
                GamepassService:Check(Frame.Name):andThen(function(Owned)
                    if Owned then
                        local toggled = table.find(self.Toggled, Frame) ~= nil
                        if toggled then
                            table.remove(self.Toggled, table.find(self.Toggled, Frame))
                        else
                            table.insert(self.Toggled, Frame)
                        end
                        GamepassService:Update(Frame.Name, not toggled)
                    else
                        MarketplaceService:PromptGamePassPurchase(Player, Gamepasses[Frame.Name].ID)
                    end
                end)
            end)
        end
    end
end

function SettingsController:AnimateTab(button, isDeselected)
    local transparency = isDeselected and 1 or 0
    local color = isDeselected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)

    AnimNation.target(button, {s = 10}, {ImageTransparency = transparency})
    AnimNation.target(button.Text, {s = 10}, {TextColor3 = color})
end

-- Return Controller to Knit.
return SettingsController
