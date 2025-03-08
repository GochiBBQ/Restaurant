--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Controller
local InventoryController = Knit.CreateController {
    Name = "InventoryController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")

local InventoryUI = GochiUI:WaitForChild("Inventory")

local Buttons = InventoryUI.Buttons
local Pages = InventoryUI.Pages

local UIController

-- Client Functions
function InventoryController:KnitStart()
    UIController = Knit.GetController("UIController")

    for _, button in pairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            button.MouseButton1Click:Connect(function()
                self:SetState(button, true)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    InventoryUI.Close.MouseButton1Click:Connect(function()
        UIController:Close(InventoryUI)
    end)
    
    InventoryUI:GetPropertyChangedSignal("Visible"):Connect(function()
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
                    button.ImageTransparency = 1
                    button.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                Button.ImageTransparency = 0
                Button.TextLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
            end
        end
    end
end

function InventoryController:OpenPage(Page: ScrollingFrame | Frame)
    assert(Page:IsA("ScrollingFrame") or Page:IsA("Frame"), "Page must be a Frame object")

    for _, page in pairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") then
            page.Visible = false
        end
    end
    Page.Visible = true
end

 -- Return Controller to Knit.
return InventoryController
