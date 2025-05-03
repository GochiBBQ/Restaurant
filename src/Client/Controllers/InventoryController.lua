--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)

local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) -- @module AnimNation
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local InventoryController = Knit.CreateController {
    Name = "InventoryController",
}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")

local InventoryUI: GuiObject = GochiUI:WaitForChild("Inventory")

local Buttons: GuiObject = InventoryUI.Buttons
local Pages: GuiObject = InventoryUI.Pages

local UIController

-- Client Functions
function InventoryController:KnitStart()
    self._trove = Trove.new()
    UIController = Knit.GetController("UIController")

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
