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

local TableService, RankService
local UIController

-- Client Functions
function TableController:KnitStart()

    TableService = Knit.GetService("TableService")
    RankService = Knit.GetService("RankService")
    UIController = Knit.GetController("UIController")

    task.defer(function()
        self:InitRegisters()
        self:InitAreaSelection()
    end)
end

function TableController:InitRegisters()
    local functionality = workspace:WaitForChild("Functionality")
    local registers = functionality:FindFirstChild("Registers")

    repeat task.wait() until #registers:GetChildren() > 0

    -- TODO:
    -- Fix register proximity prompt not working

    if registers then
        for _, register in ipairs(registers:GetChildren()) do
            if register:FindFirstChild("Screen") and register.Screen:FindFirstChild("ProximityPrompt") then

                RankService:Get():andThen(function(Rank, Role)
                    print(Rank)
                    if Rank < 4 then
                        register.Screen.ProximityPrompt.Enabled = false
                    end
                end)

                register.Screen.ProximityPrompt.Triggered:Connect(function()
                    UIController:Open(TableUI.AreaSelection)
                    TableService:TabletInit(register)
                end)
            end

            TableUI.AreaSelection:GetPropertyChangedSignal("Visible"):Connect(function()
                if not TableUI.AreaSelection.Visible then
                    TableService:TabletEnd(register)
                end
            end)
        end
    end
end

function TableController:InitAreaSelection()

    -- TODO:
    -- Check if the player is already seated at a table
    -- Check if party leader left server

    local AreaSelectionUI = TableUI:WaitForChild("AreaSelection")
    local GuestOptions = AreaSelectionUI:WaitForChild("GuestOptions")
    local ButtonSelection = AreaSelectionUI:WaitForChild("AreaButtons")
    local Guests

    GuestOptions.Title.Text = `Hello, <b>{Player.DisplayName}</b>! To continue, please enter the number of guests you wish to seat.`

    local function Close()
        UIController:Close(AreaSelectionUI)
        GuestOptions.Visible = true
        
        for _, child in ButtonSelection:GetChildren() do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end

        GuestOptions.Entry.Text = ""
    end

    AreaSelectionUI.Close.MouseButton1Click:Connect(Close)

    GuestOptions.Submit.MouseButton1Click:Connect(function()
        Guests = GuestOptions.Entry.Text

        if Guests == "" or tonumber(Guests) == nil or tonumber(Guests) > 8 or tonumber(Guests) < 1 then
            GuestOptions.Entry.Text = ""
            GuestOptions.Entry.PlaceholderText = "Invalid Entry"

            task.delay(2, function()
                GuestOptions.Entry.PlaceholderText = "Number of Guests"
            end)

            return
        end

        GuestOptions.Visible = false

        for _, child in ButtonSelection:GetChildren() do
            if child:IsA("Frame") then
                child.Visible = true
            end
        end

        -- Check available tables and update button UIs
        TableService:GetAvailable(Guests):andThen(function(data)
            for _, child in ButtonSelection:GetChildren() do
                if child:IsA("Frame") then
                    local area = child.Name
                    local tables = data[area]

                    child.Description.Text = `There are <b>{#tables}</b> tables available in this section that can seat <b>{Guests}</b> guests.`

                    if #tables == 0 then
                        child.Select.Label.Text = "Unavailable"
                        AnimNation.target(child.Select, {s = 3, d = 0.3}, {ImageColor3 = Color3.fromRGB(0, 0, 0)})
                        child.Select.Selectable = false
                    else
                        child.Select.Label.Text = "Select"
                        AnimNation.target(child.Select, {s = 3, d = 0.3}, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
                        child.Select.Selectable = true
                    end
                end
            end
        end)

    end)
end

 -- Return Controller to Knit.
return TableController
