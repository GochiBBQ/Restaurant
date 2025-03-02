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

-- use trove for disconnections instead of variables

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
    ["Headless"] = {
        ID = 1002697699,
    },
    ["Korblox"] = {
        ID = 1004797619,
    },
    ["Walkspeed"] = {
        ID = 1003057662,
    },
    ["DisableUniform"] = {
        ID = 1003177642,
    },
}

-- Client Functions
function SettingsController:KnitStart()

    DataService = Knit.GetService("DataService")
    GamepassService = Knit.GetService("GamepassService")

    DataService:Get():andThen(function(Settings)
        for Setting, Toggle in pairs(Settings) do
            local Frame = SettingsUI:WaitForChild("Settings"):WaitForChild(Setting)
            if Frame then
                if Toggle then
                    table.insert(self.Toggled, Frame)

                    if Setting == "MuteMusic" then
                        TweenService:Create(workspace.Music, TweenInfo.new(1), {Volume = 0.5}):Play()
                    end
                else
                    if Setting == "MuteMusic" then
                        workspace.Music.Volume = 0
                    end
                end
            end
        end
    end)

    DataService.UpdateSettings:Connect(function(Setting, Type)
        local Frame = SettingsUI:WaitForChild("Settings"):WaitForChild(Setting)
        if Frame then
            local Switch = Frame:WaitForChild("Switch")
            local ToggleObject = Switch:WaitForChild("Toggle")
            local Background = Switch:WaitForChild("Background")

            if Type then
                -- spr.target(ToggleObject, 0.5, 3, {Position = Toggles.Selected.Position})
                AnimNation.target(ToggleObject, {s = 10, d = 0.5}, {Position = Toggles.Selected.Position})
                Background.Image = Toggles.Selected.Image
                table.insert(self.Toggled, Frame)

                if Setting == "MuteMusic" then
                    TweenService:Create(workspace.Music, TweenInfo.new(1), {Volume = 0.5}):Play()
                end
            else
                -- spr.target(ToggleObject, 0.5, 3, {Position = Toggles.Deselected.Position})
                AnimNation.target(ToggleObject, {s = 10, d = 0.5}, {Position = Toggles.Deselected.Position})
                Background.Image = Toggles.Deselected.Image

                if Setting == "MuteMusic" then
                    workspace.Music.Volume = 0
                end
            end
        end
    end)

    GamepassService:Get():andThen(function(Gamepasses)
        for Gamepass, Toggle in pairs(Gamepasses) do
            local Frame = SettingsUI:WaitForChild("Gamepasses"):WaitForChild(Gamepass)
            if Frame then
                if Toggle then
                    table.insert(self.Toggled, Frame)
                end
            end
        end
    end)

    GamepassService.UpdateSettings:Connect(function(Gamepass, Type)
        local Frame = SettingsUI:WaitForChild("Gamepasses"):WaitForChild(Gamepass)
        if Frame then
            local Switch = Frame:WaitForChild("Switch")
            local ToggleObject = Switch:WaitForChild("Toggle")
            local Background = Switch:WaitForChild("Background")

            if Type then
                -- spr.target(ToggleObject, 0.5, 3, {Position = Toggles.Selected.Position})
                AnimNation.target(ToggleObject, {s = 10, d = 0.5}, {Position = Toggles.Selected.Position})
                Background.Image = Toggles.Selected.Image
                table.insert(self.Toggled, Frame)
            else
                -- spr.target(ToggleObject, 0.5, 3, {Position = Toggles.Deselected.Position})
                AnimNation.target(ToggleObject, {s = 10, d = 0.5}, {Position = Toggles.Deselected.Position})
                Background.Image = Toggles.Deselected.Image
            end
        end
    end)

    local function updateButtonAppearance(button, transparency, textColor)
        -- spr.target(button, 0.5, 3, {ImageTransparency = transparency})
        AnimNation.target(button, {s = 10, d = 0.5}, {ImageTransparency = transparency})
       -- spr.target(button.Text, 0.5, 3, {TextColor3 = textColor})
        AnimNation.target(button.Text, {s = 10, d = 0.5}, {TextColor3 = textColor})
    end

    local function onButtonClick(button)
        SettingsUI[self.Selected].Visible = false
        updateButtonAppearance(SettingsUI.Buttons.List[self.Selected], 1, Color3.fromRGB(255, 255, 255))
        self.Selected = button.Name
        SettingsUI[self.Selected].Visible = true
        updateButtonAppearance(button, 0, Color3.fromRGB(30, 30, 30))
    end

    for _, button in pairs(SettingsUI:WaitForChild("Buttons").List:GetChildren()) do
        if button:IsA("ImageButton") then
            button.MouseButton1Click:Connect(function()
                onButtonClick(button)
            end)
        end
    end

    task.delay(5, function()
        self:InitSettings()
        self:InitGamepasses()
    end)
end

function SettingsController:InitSettings()
    for _, Frame in pairs(SettingsUI:WaitForChild("Settings"):GetChildren()) do
        if Frame:IsA("Frame") then
            local Switch = Frame:WaitForChild("Switch")
            local ToggleObject = Switch:WaitForChild("Toggle")
            local Background = Switch:WaitForChild("Background")

            if table.find(self.Toggled, Frame) then
                -- spr.target(ToggleObject, 0.5, 1, {Position = Toggles.Selected.Position})
                AnimNation.target(ToggleObject, {s = 7, d = 0.5}, {Position = Toggles.Selected.Position})
                Background.Image = Toggles.Selected.Image
            else
                -- spr.target(ToggleObject, 0.5, 1, {Position = Toggles.Deselected.Position})
                AnimNation.target(ToggleObject, {s = 7, d = 0.5}, {Position = Toggles.Deselected.Position})
                Background.Image = Toggles.Deselected.Image           
            end

            Switch.MouseButton1Click:Connect(function()
                if table.find(self.Toggled, Frame) then
                    table.remove(self.Toggled, table.find(self.Toggled, Frame))
                    DataService:Update(Frame.Name, false)
                else
                    table.insert(self.Toggled, Frame)
                    DataService:Update(Frame.Name, true)
                end
            end)
        end
    end
end

function SettingsController:InitGamepasses()
    for _, Frame in pairs(SettingsUI:WaitForChild("Gamepasses"):GetChildren()) do
        if Frame:IsA("Frame") then
            local Switch = Frame:WaitForChild("Switch")
            local ToggleObject = Switch:WaitForChild("Toggle")
            local Background = Switch:WaitForChild("Background")

            if table.find(self.Toggled, Frame) then
                -- spr.target(ToggleObject, 0.5, 1, {Position = Toggles.Selected.Position})
                AnimNation.target(ToggleObject, {s = 5, d = 0.5}, {Position = Toggles.Selected.Position})
                Background.Image = Toggles.Selected.Image
            else
                -- spr.target(ToggleObject, 0.5, 1, {Position = Toggles.Deselected.Position})
                AnimNation.target(ToggleObject, {s = 5, d = 0.5}, {Position = Toggles.Deselected.Position})
                Background.Image = Toggles.Deselected.Image           
            end

            Switch.MouseButton1Click:Connect(function()
                GamepassService:Check(Frame.Name):andThen(function(Owned)
                    if Owned then
                        if table.find(self.Toggled, Frame) then
                            table.remove(self.Toggled, table.find(self.Toggled, Frame))
                            GamepassService:Update(Frame.Name, false)
                        else
                            table.insert(self.Toggled, Frame)
                            GamepassService:Update(Frame.Name, true)
                        end
                    else
                        MarketplaceService:PromptGamePassPurchase(Player, Gamepasses[Frame.Name].ID)
                    end
                end)
            end)
        end
    end
end

-- Return Controller to Knit.
return SettingsController
