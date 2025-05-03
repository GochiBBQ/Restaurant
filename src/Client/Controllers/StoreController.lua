--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove)
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) --- @module AnimNation

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

local UIController
local _trove = Trove.new()

-- Client Functions
function StoreController:KnitStart()
    UIController = Knit.GetController("UIController")

    for _, button in ipairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            _trove:Connect(button.MouseButton1Click, function()
                if self.Selected ~= button.Name then
                    Pages[self.Selected].Visible = false
                    self:AnimateTab(Buttons.List[self.Selected], true)

                    self.Selected = button.Name
                    Pages[self.Selected].Visible = true
                    self:AnimateTab(button, false)
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
                end
            end
        end
    end
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

function StoreController:AnimateTab(button: ImageButton, isDeselected: boolean)
    local transparency = isDeselected and 1 or 0
    local color = isDeselected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)

    AnimNation.target(button, {s = 10, d = 0.5}, {ImageTransparency = transparency})
    AnimNation.target(button.TextLabel, {s = 10, d = 0.5}, {TextColor3 = color})
end

-- Return Controller to Knit.
return StoreController
