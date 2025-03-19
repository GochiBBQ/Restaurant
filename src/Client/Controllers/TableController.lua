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
local Panel = GochiUI:WaitForChild("TableManagementPanel")

local Content = TableUI:WaitForChild("Content")

local TableService, RankService, NotificationService
local UIController

local uiOpen = false
local activeRegister = nil


-- Client Functions
function TableController:KnitStart()

    TableService = Knit.GetService("TableService")
    RankService = Knit.GetService("RankService")
    NotificationService = Knit.GetService("NotificationService")
    UIController = Knit.GetController("UIController")

    local Functionality = workspace:WaitForChild("Functionality")
    local registers = Functionality:WaitForChild("Registers")

    task.spawn(function()
        repeat task.wait() until #registers:GetChildren() > 0
        self:InitRegisters()
    end)

    task.defer(function()
        self:InitUI()
    end)

end

function TableController:InitUI()
    TableUI.Close.Activated:Connect(function()
        uiOpen = false
        UIController:Close(TableUI)
    end)

    Panel.Close.Activated:Connect(function()
        uiOpen = false
        UIController:Close(Panel)
    end)

    TableService:GetCount():andThen(function(data)
        for area, count in data do
            local frame = Content:WaitForChild(area)

            if frame then
                frame.Int.Text = `<b>{count}</b> tables available`
            end
        end
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
                AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.494, 0, 0.877, 0)})
                AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.494, 0,0.94, 0)})
                AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.494, 0, 1.147, 0)}):AndThen(function()
                    frame.SelectButton.Visible = false
                end)
            end)

            -- frame.SelectButton.MouseEnter:Connect(function()
            --     AnimNation.target(frame.SelectButton, {s = 20}, {Size = UDim2.new(0.88, 0, 0.125, 0)})
            -- end)

            -- frame.SelectButton.MouseLeave:Connect(function()
            --     AnimNation.target(frame.SelectButton, {s = 20}, {Size = UDim2.new(0.899, 0, 0.131, 0)})
            -- end)

            frame.SelectButton.Activated:Connect(function()
                self:AreaSelected(frame.Name)
            end)

        end
    end

    for _, button in pairs(Panel:GetDescendants()) do
        if button:IsA("GuiButton") and button.Name ~= "Close" then
            local scaleFactor = UDim2.new(0.02, 0, 0.02, 0)
            local originalSize = button.Size

            button.MouseEnter:Connect(function()
                AnimNation.target(button, {s = 20}, {Size = originalSize - scaleFactor})
            end)

            button.MouseLeave:Connect(function()
                AnimNation.target(button, {s = 20}, {Size = originalSize})
            end)
        end
    end

    for _, button in pairs(Content:GetDescendants()) do
        if button:IsA("GuiButton") then
            local scaleFactor = UDim2.new(0.02, 0, 0.02, 0)
            local originalSize = button.Size

            button.MouseEnter:Connect(function()
                AnimNation.target(button, {s = 20}, {Size = originalSize - scaleFactor})
            end)

            button.MouseLeave:Connect(function()
                AnimNation.target(button, {s = 20}, {Size = originalSize})
            end)
        end
    end
end

function TableController:InitRegisters()
    local Functionality = workspace:WaitForChild("Functionality")
    local registers = Functionality:WaitForChild("Registers")

    RankService:Get():andThen(function(Rank)

        if Rank < 4 then
            for _, register in ipairs(registers:GetChildren()) do
                if register:FindFirstChild("Screen") and register.Screen:FindFirstChild("ProximityPrompt") then
                    register.Screen.ProximityPrompt:Destroy()
                end
            end
            return
        else
            for _, register in ipairs(registers:GetChildren()) do
                if register:FindFirstChild("Screen") and register.Screen:FindFirstChild("ProximityPrompt") then
                    register.Screen.ProximityPrompt.Triggered:Connect(function()
                        uiOpen = true
                        activeRegister = register
                        UIController:Open(TableUI)
                        TableService:TabletInit(register)
                    end)
    
                    register:GetAttributeChangedSignal("InUse"):Connect(function()
                        local inUse = register:GetAttribute("InUse")
                        if not inUse then
                            register.Screen.ProximityPrompt.Enabled = false
                            task.wait(0.1)
                            register.Screen.ProximityPrompt.Enabled = true
                        else
                            register.Screen.ProximityPrompt.Enabled = false
                        end
                    end)                    
    
                    local function checkUIVisibility()
                        if not uiOpen and activeRegister then
                            TableService:TabletEnd(activeRegister)
                            activeRegister = nil
                        end
                    end
    
                    Panel:GetPropertyChangedSignal("Visible"):Connect(checkUIVisibility)
                    TableUI:GetPropertyChangedSignal("Visible"):Connect(checkUIVisibility)
                end
            end
        end
    end)
end

function TableController:AreaSelected(Area: string)
    UIController:Close(TableUI)
    UIController:Open(Panel)

    local GuestSelection = Panel:WaitForChild("GuestSelection")

    GuestSelection.Section.Text = `Section: <b>{Area}</b>`

    GuestSelection.OrderOptions.GuestInput.TextLabel.Text = ""

    local originalSize = GuestSelection.OrderOptions.Confirm.Size

    GuestSelection.OrderOptions.Confirm.MouseEnter:Connect(function()
        local scaleFactor = UDim2.new(0.02, 0, 0.02, 0)
        AnimNation.target(GuestSelection.OrderOptions.Confirm, {s = 20}, {Size = originalSize - scaleFactor})
    end)

    GuestSelection.OrderOptions.Confirm.MouseLeave:Connect(function()
        AnimNation.target(GuestSelection.OrderOptions.Confirm, {s = 20}, {Size = originalSize})
    end)

    local function HandleParty(OrderOptions, PartyView, PlayerInput, ExistingPlayers, PlayersToAdd)
        OrderOptions.AddButton.Activated:Connect(function()
            if OrderOptions.PlayerInput.TextLabel.Text == "" then
                OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Invalid Entry"
                task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
                return
            end

            local PlayerToAdd = Players:FindFirstChild(OrderOptions.PlayerInput.TextLabel.Text)
            OrderOptions.PlayerInput.TextLabel.Text = ""

            if not PlayerToAdd then
                OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Invalid Entry"
                task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
                return
            end

            if table.find(ExistingPlayers, PlayerToAdd) or table.find(PlayersToAdd, PlayerToAdd) then
                OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Already in Party"
                task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
                return
            end

            if PlayerToAdd:GetAttribute("InParty") then
                OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Player in Different Party"
                task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
                return
            end

            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size420x420
            local occupantHeadshot = Players:GetUserThumbnailAsync(PlayerToAdd.UserId, thumbType, thumbSize)

            local frame = PartyView.ScrollingFrame.Template:Clone()
            frame.Name = PlayerToAdd.Name
            frame.PlayerName.Text = PlayerToAdd.Name
            frame.PlayerImage.Image = occupantHeadshot
            frame.Visible = true
            frame.Parent = PartyView.ScrollingFrame

            table.insert(PlayersToAdd, PlayerToAdd)
            NotificationService:CreateNotif(PlayerToAdd, `You have been added to a party by <b>{Player.Name}</b>.`)
        end)

        OrderOptions.MinusButton.Activated:Connect(function()
            if PlayerInput.Text == "" then
                PlayerInput.PlaceholderText = "Invalid Entry"
                task.delay(2, function() PlayerInput.PlaceholderText = "Username" end)
                return
            end

            local PlayerToRemove = nil
            for i, player in ipairs(PlayersToAdd) do
                if player.Name == PlayerInput.Text then
                    PlayerToRemove = player
                    table.remove(PlayersToAdd, i)
                    break
                end
            end

            if not PlayerToRemove then
                for i, player in ipairs(ExistingPlayers) do
                    if player.Name == PlayerInput.Text then
                        PlayerToRemove = player
                        table.remove(ExistingPlayers, i)
                        break
                    end
                end
            end

            PlayerInput.Text = ""

            if not PlayerToRemove then
                PlayerInput.PlaceholderText = "Player Not Found"
                task.delay(2, function() PlayerInput.PlaceholderText = "Username" end)
                return
            end

            local frame = PartyView.ScrollingFrame:FindFirstChild(PlayerToRemove.Name)
            if frame then
                frame:Destroy()
            end
            NotificationService:CreateNotif(PlayerToRemove, `You have been removed from a party by <b>{Player.Name}</b>.`)
        end)
    end

    local function PartyExists(tableData)
        local panelContent = Panel.Content
        local OrderOptions = panelContent:WaitForChild("OrderOptions")
        local PartyView = panelContent:WaitForChild("PartyView")
        local PlayerInput = OrderOptions.PlayerInput.TextLabel

        local ExistingPlayers = {}
        local PlayersToAdd = {}

        local Occupants = tableData.Occupants or {}

        for _, occupant in ipairs(Occupants) do
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size420x420
            local occupantHeadshot = Players:GetUserThumbnailAsync(occupant.UserId, thumbType, thumbSize)

            local frame = PartyView.ScrollingFrame.Template:Clone()
            frame.Name = occupant.Name
            frame.PlayerName.Text = occupant.Name
            frame.PlayerImage.Image = occupantHeadshot
            frame.Visible = true
            frame.Parent = PartyView.ScrollingFrame

            table.insert(ExistingPlayers, occupant)
        end

        HandleParty(OrderOptions, PartyView, PlayerInput, ExistingPlayers, PlayersToAdd)
    end

    local function NewParty()
        local panelContent = Panel.Content
        local OrderOptions = panelContent:WaitForChild("OrderOptions")
        local PartyView = panelContent:WaitForChild("PartyView")
        local PlayerInput = OrderOptions.PlayerInput.TextLabel

        local PlayersToAdd = {}

        HandleParty(OrderOptions, PartyView, PlayerInput, {}, PlayersToAdd)
    end

    GuestSelection.OrderOptions.Confirm.Activated:Connect(function()
        local Guests = GuestSelection.OrderOptions.GuestInput.TextLabel.Text

        if Guests == "" or tonumber(Guests) == nil or tonumber(Guests) > 8 or tonumber(Guests) < 1 then
            GuestSelection.OrderOptions.GuestInput.TextLabel.Text = ""
            GuestSelection.OrderOptions.GuestInput.TextLabel.PlaceholderText = "Invalid Entry"

            task.delay(2, function()
                GuestSelection.OrderOptions.GuestInput.TextLabel.PlaceholderText = "# of Guests"
            end)

            return
        end

        TableService:Claim(Area, Guests):andThen(function(success, tableData)
            if not success then return end

            local Name = string.match(tableData.Name, "%d+")
            local Occupants = tableData.Occupants or {}
            local panelContent = Panel.Content

            panelContent.Section.Text = `Section: <b>{tableData.Category}</b>`
            panelContent.Title.Text = `Your party is assigned to Table <b>{Name}</b>`

            GuestSelection.Visible = false
            panelContent.Visible = true

            if #Occupants > 0 then
                PartyExists(tableData)
            else
                NewParty()
            end

        end)
    end)
end

 -- Return Controller to Knit.
return TableController
