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
local TableController = Knit.CreateController {
    Name = "TableController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local TableUI = GochiUI:WaitForChild("TableManagement")

local Content = TableUI:WaitForChild("Content")

local TableService, RankService
local UIController

-- Client Functions
function TableController:KnitStart()

    TableService = Knit.GetService("TableService")
    RankService = Knit.GetService("RankService")
    UIController = Knit.GetController("UIController")

    local Functionality = workspace:WaitForChild("Functionality")
    local registers = Functionality:WaitForChild("Registers")

    task.spawn(function()
        repeat task.wait() until #registers:GetChildren() > 0
        self:InitRegisters()
    end)

    task.defer(function()
        self:InitUI()
        -- self:InitAreaSelection()
    end)

end

function TableController:InitUI()
    TableUI.Close.Activated:Connect(function()
        UIController:Close(TableUI)
    end)

    for _, frame in pairs(Content:GetChildren()) do
        if frame:IsA("Frame") then

            frame.MouseEnter:Connect(function()
                AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.5, 0, 0.775, 0)})
                AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.5, 0, 0.71, 0)})
                frame.SelectButton.Visible = true
                AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.5, 0, 0.897, 0)}):AndThen(function()
                    frame.SelectButton.Visible = true
                end)
            end)

            frame.MouseLeave:Connect(function()
                AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.494, 0, 0.877, 0)})
                AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.494, 0,0.94, 0)})
                AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.494, 0, 1.147, 0)}):AndThen(function()
                    frame.SelectButton.Visible = false
                end)
            end)

            frame.SelectButton.MouseEnter:Connect(function()
                AnimNation.target(frame.SelectButton, {s = 20}, {Size = UDim2.new(0.88, 0, 0.125, 0)})
            end)

            frame.SelectButton.MouseLeave:Connect(function()
                AnimNation.target(frame.SelectButton, {s = 20}, {Size = UDim2.new(0.899, 0, 0.131, 0)})
            end)

        end
    end
end

function TableController:InitRegisters()
    local Functionality = workspace:WaitForChild("Functionality")
    local registers = Functionality:WaitForChild("Registers")

    RankService:Get():andThen(function(Rank)
        for _, register in ipairs(registers:GetChildren()) do
            if register:FindFirstChild("Screen") and register.Screen:FindFirstChild("ProximityPrompt") then
                if Rank < 4 then
                    register.Screen.ProximityPrompt.Enabled = false
                end

                register.Screen.ProximityPrompt.Triggered:Connect(function()
                    UIController:Open(TableUI)
                    TableService:TabletInit(register)
                end)

                TableUI:GetPropertyChangedSignal("Visible"):Connect(function()
                    if not TableUI.Visible then
                        TableService:TabletEnd(register)
                    end
                end)
            end
        end
    end)
end

-- function TableController:InitAreaSelection()

--     -- TODO:
--     -- Check if the player is already seated at a table
--     -- Check if party leader left server

--     local AreaSelectionUI = TableUI:WaitForChild("AreaSelection")
--     local GuestOptions = AreaSelectionUI:WaitForChild("GuestOptions")
--     local ButtonSelection = AreaSelectionUI:WaitForChild("AreaButtons")
--     local Guests

--     GuestOptions.Title.Text = `Hello, <b>{Player.DisplayName}</b>! To continue, please enter the number of guests you wish to seat.`

--     local function Close()
--         UIController:Close(AreaSelectionUI)
--         GuestOptions.Visible = true
        
--         for _, child in ButtonSelection:GetChildren() do
--             if child:IsA("Frame") then
--                 child.Visible = false
--             end
--         end

--         GuestOptions.Entry.Text = ""
--     end

--     AreaSelectionUI.Close.MouseButton1Click:Connect(Close)

--     GuestOptions.Submit.MouseButton1Click:Connect(function()
--         Guests = GuestOptions.Entry.Text

--         if Guests == "" or tonumber(Guests) == nil or tonumber(Guests) > 8 or tonumber(Guests) < 1 then
--             GuestOptions.Entry.Text = ""
--             GuestOptions.Entry.PlaceholderText = "Invalid Entry"

--             task.delay(2, function()
--                 GuestOptions.Entry.PlaceholderText = "Number of Guests"
--             end)

--             return
--         end

--         GuestOptions.Visible = false

--         for _, child in ButtonSelection:GetChildren() do
--             if child:IsA("Frame") then
--                 child.Visible = true
--             end
--         end

--         -- Check available tables and update button UIs
--         TableService:GetAvailable(Guests):andThen(function(data)
--             for _, child in ButtonSelection:GetChildren() do
--                 if child:IsA("Frame") then
--                     local area = child.Name
--                     local tables = data[area]

--                     child.Description.Text = `There are <b>{#tables}</b> tables available in this section that can seat <b>{Guests}</b> guests.`

--                     if #tables == 0 then
--                         child.Select.Label.Text = "Unavailable"
--                         AnimNation.target(child.Select, {s = 3, d = 0.3}, {ImageColor3 = Color3.fromRGB(0, 0, 0)})
--                         child.Select.Selectable = false
--                     else
--                         child.Select.Label.Text = "Select"
--                         AnimNation.target(child.Select, {s = 3, d = 0.3}, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
--                         child.Select.Selectable = true
--                     end
--                 end
--             end
--         end)

--     end)
-- end

 -- Return Controller to Knit.
return TableController
