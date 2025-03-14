--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation

-- Create Knit Controller
local StoreController = Knit.CreateController {
    Name = "StoreController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")

local StoreUI = GochiUI:WaitForChild("Store")

local Buttons = StoreUI.Buttons
local Pages = StoreUI.Pages

local UIController

-- Client Functions
function StoreController:KnitStart()
    UIController = Knit.GetController("UIController")

    for _, button in pairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            button.MouseButton1Click:Connect(function()
                self:SetState(button, true)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    StoreUI.Close.MouseButton1Click:Connect(function()
        UIController:Close(StoreUI)
    end)
    
    StoreUI:GetPropertyChangedSignal("Visible"):Connect(function()
        if not StoreUI.Visible then
            self:SetState(Buttons.List.Featured, true)
            self:OpenPage(Pages.Featured)
        end
    end)

    for _, page in pairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") then
            for _, child in pairs(page:GetChildren()) do
                if child:IsA("Frame") then

                    -- Play gradient change background animation on mouse enter
                    child.MouseEnter:Connect(function()
                        AnimNation.target(child, {s = 8}, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.85})
                    end)

                    -- Play gradient change background animation on mouse leave
                    child.MouseLeave:Connect(function()
                        AnimNation.target(child, {s = 8}, {BackgroundColor3 = Color3.fromRGB(102, 102, 102), BackgroundTransparency = 0.65})
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
        for _, button in pairs(Buttons.List:GetChildren()) do
            if button:IsA("ImageButton") then
                if button ~= Button then
                    button.ImageTransparency = 1
                    button.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                Button.ImageTransparency = 0
                Button.TextLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
            end
        end
    end
end

function StoreController:OpenPage(Page: ScrollingFrame | Frame)
    assert(Page:IsA("ScrollingFrame") or Page:IsA("Frame"), "Page must be a Frame object")

    for _, page in pairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") or page:IsA("Frame") then
            page.Visible = false
        end
    end
    Page.Visible = true
end

 -- Return Controller to Knit.
return StoreController
