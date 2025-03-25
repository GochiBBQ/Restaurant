--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService: UserInputService = game:GetService("UserInputService")

local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService('RunService')

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) --- @module AnimNation
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local TableController = Knit.CreateController {
    Name = "TableController",
}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")
local TableUI: GuiObject = GochiUI:WaitForChild("TableManagement")
local Panel: GuiObject = GochiUI:WaitForChild("TableManagementPanel")

local Content: GuiObject = TableUI:WaitForChild("Content")

local TableService, RankService, NotificationService, NavigationService
local UIController

local uiOpen: boolean = false
local activeRegister: Instance = nil
local currentTable: Instance = nil

local selectedOption: string = nil

-- Global Variables
local ExistingPlayers: {Player} = {}
local PlayersToAdd: {Player} = {}

local partyTrove = Trove.new()

-- Reset function for global variables
local function ResetPartyData(fullReset: boolean?)
    print("Resetting party data...")

    ExistingPlayers = {}
    PlayersToAdd = {}

    local panelContent = Panel.Content
    local PartyView = panelContent:WaitForChild("PartyView")

    for _, child in PartyView.ScrollingFrame:GetChildren() do
        if child:IsA("Frame") and child.Name ~= "Template" then
            child:Destroy()
        end
    end

    panelContent.OrderOptions.PlayerInput.TextLabel.Text = ""
    panelContent.OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username"

    if fullReset then

        UIController:Close(Panel)
        UIController:Close(TableUI)

        uiOpen = false
        panelContent.Visible = false
        Panel.GuestSelection.Visible = true
        currentTable = nil
        selectedOption = nil
    end

    return true
end


-- Move HandleParty to a higher scope

local function HandleParty(OrderOptions, PartyView, PlayerInput)
    partyTrove:Clean() -- Clean up previous listeners

    partyTrove:Connect(OrderOptions.AddButton.Activated, function()
        print("AddButton activated")
        if OrderOptions.PlayerInput.TextLabel.Text == "" then
            warn("Invalid entry: Empty username")
            OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Invalid Entry"
            task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
            return
        end

        local PlayerToAdd = Players:FindFirstChild(OrderOptions.PlayerInput.TextLabel.Text)
        OrderOptions.PlayerInput.TextLabel.Text = ""

        if not PlayerToAdd then
            warn("Player not found: " .. OrderOptions.PlayerInput.TextLabel.Text)
            OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Invalid Entry"
            task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
            return
        end

        if PlayerToAdd == Player then
            warn("Cannot add yourself to the party")
            OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Cannot add yourself"
            task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
            return
        end

        if PlayerToAdd:GetAttribute("Table") ~= nil then
            warn("Player already assigned to a table")
            OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Player in Different Party"
            task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
            return
        end

        if table.find(ExistingPlayers, PlayerToAdd) or table.find(PlayersToAdd, PlayerToAdd) then
            warn("Player already in the party")
            OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Already in Party"
            task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
            return
        end

        if PlayerToAdd:GetAttribute("InParty") then
            warn("Player is already in a different party")
            OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Player in Different Party"
            task.delay(2, function() OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Username" end)
            return
        end

        local success, occupantHeadshot = pcall(function()
            return Players:GetUserThumbnailAsync(PlayerToAdd.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)

        if not success then
            warn("Failed to fetch player thumbnail for " .. PlayerToAdd.Name)
            return
        end

        if selectedOption == 'New' then
            local frame = PartyView.ScrollingFrame.Template:Clone()
            frame.Name = PlayerToAdd.Name
            frame.PlayerName.Text = PlayerToAdd.Name
            frame.PlayerImage.Image = occupantHeadshot
            frame.Visible = true
            frame.Parent = PartyView.ScrollingFrame

            table.insert(PlayersToAdd, PlayerToAdd)
            print("Player added to party: " .. PlayerToAdd.Name)
            NotificationService:CreateNotif(PlayerToAdd, `You have been added to a party by <b>{Player.Name}</b>.`)
        elseif selectedOption == 'Existing' then
            TableService:AddOccupant(currentTable, PlayerToAdd):andThen(function(success)
                if success then
                    local frame = PartyView.ScrollingFrame.Template:Clone()
                    frame.Name = PlayerToAdd.Name
                    frame.PlayerName.Text = PlayerToAdd.Name
                    frame.PlayerImage.Image = occupantHeadshot
                    frame.Visible = true
                    frame.Parent = PartyView.ScrollingFrame

                    table.insert(PlayersToAdd, PlayerToAdd)
                    print("Player added to existing party: " .. PlayerToAdd.Name)
                    NotificationService:CreateNotif(PlayerToAdd, `You have been added to a party by <b>{Player.Name}</b>.`)
                else
                    warn("Failed to add player to existing party: " .. PlayerToAdd.Name)
                    OrderOptions.PlayerInput.TextLabel.PlaceholderText = "Failed to add player"
                end
            end)
        end
    end)

    partyTrove:Connect(OrderOptions.MinusButton.Activated, function()
        print("MinusButton activated")
        warn(selectedOption)
        if PlayerInput.Text == "" then
            warn("Invalid entry: Empty username")
            PlayerInput.PlaceholderText = "Invalid Entry"
            task.delay(2, function() PlayerInput.PlaceholderText = "Username" end)
            return
        end

        local PlayerToRemove = nil
        for i, player in ipairs(PlayersToAdd) do
            if player.Name == PlayerInput.Text then
                PlayerToRemove = player
                break
            end
        end

        if not PlayerToRemove then
            for i, player in ipairs(ExistingPlayers) do
                if player.Name == PlayerInput.Text then
                    PlayerToRemove = player
                    break
                end
            end
        end

        PlayerInput.Text = ""

        if not PlayerToRemove then
            warn("Player not found for removal: " .. PlayerInput.Text)
            PlayerInput.PlaceholderText = "Player Not Found"
            task.delay(2, function() PlayerInput.PlaceholderText = "Username" end)
            return
        end

        if selectedOption == 'New' then
            local frame = PartyView.ScrollingFrame:FindFirstChild(PlayerToRemove.Name)
            if frame then
                frame:Destroy()
            end

            -- Remove the player from the appropriate table only after success
            for i, player in ipairs(PlayersToAdd) do
                if player == PlayerToRemove then
                    table.remove(PlayersToAdd, i)
                    break
                end
            end

            for i, player in ipairs(ExistingPlayers) do
                if player == PlayerToRemove then
                    table.remove(ExistingPlayers, i)
                    break
                end
            end

            print("Player removed from party: " .. PlayerToRemove.Name)
            NotificationService:CreateNotif(PlayerToRemove, `You have been removed from a party by <b>{Player.Name}</b>.`)
        elseif selectedOption == 'Existing' then
            print("Removing player from existing party: " .. PlayerToRemove.Name)
            warn(#ExistingPlayers + #PlayersToAdd)
            if (#ExistingPlayers + #PlayersToAdd == 1) then
                TableService:SetUnoccupied(currentTable):andThen(function(success)
                    print(`Success: {success}`)
                    if success then
                        local frame = PartyView.ScrollingFrame:FindFirstChild(PlayerToRemove.Name)
                        if frame then
                            frame:Destroy()
                        end

                        ResetPartyData(true)
                        NotificationService:CreateNotif(Player, `Your table has been vacated.`)
                    end
                end)
            else
                TableService:RemoveOccupant(currentTable, PlayerToRemove):andThen(function(success)
                    if success then
                        local frame = PartyView.ScrollingFrame:FindFirstChild(PlayerToRemove.Name)
                        if frame then
                            frame:Destroy()
                        end
    
                        -- Remove the player from the appropriate table only after success
                        for i, player in ipairs(PlayersToAdd) do
                            if player == PlayerToRemove then
                                table.remove(PlayersToAdd, i)
                                break
                            end
                        end
    
                        for i, player in ipairs(ExistingPlayers) do
                            if player == PlayerToRemove then
                                table.remove(ExistingPlayers, i)
                                break
                            end
                        end
    
                        print("Player removed from existing party: " .. PlayerToRemove.Name)
                        NotificationService:CreateNotif(PlayerToRemove, `You have been removed from a party by <b>{Player.Name}</b>.`)
                    else
                        warn("Failed to remove player from existing party: " .. PlayerToRemove.Name)
                        PlayerInput.PlaceholderText = "Failed to remove player"
                    end
                end)
            end
        end
    end)

    -- Cleanup connections when UI is closed
    Panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if not Panel.Visible then
            partyTrove:Clean()
        end
    end)
end

-- Move PartyExists to a higher scope
local function PartyExists(tableData)
    print("Checking if party exists for table data...")
    local result = ResetPartyData(false)

    if result then

        currentTable = tableData.Table

        local Name = string.match(tableData.Name, "%d+")

        local panelContent = Panel.Content

        panelContent.Section.Text = `Section: <b>{tableData.Category}</b>`
        panelContent.Title.Text = `Your party is assigned to Table <b>{Name}</b>`

        local OrderOptions = panelContent:WaitForChild("OrderOptions")
        local PartyView = panelContent:WaitForChild("PartyView")
        local PlayerInput = OrderOptions.PlayerInput.TextLabel
    
        local Occupants = tableData.Occupants or {}
    
        for _, occupant in ipairs(Occupants) do
            local success, occupantHeadshot = pcall(function()
                return Players:GetUserThumbnailAsync(occupant.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end)
    
            if not success then
                warn("Failed to fetch occupant thumbnail for " .. occupant.Name)
                continue
            end
    
            local frame = PartyView.ScrollingFrame.Template:Clone()
            frame.Name = occupant.Name
            frame.PlayerName.Text = occupant.Name
            frame.PlayerImage.Image = occupantHeadshot
            frame.Visible = true
            frame.Parent = PartyView.ScrollingFrame
    
            table.insert(ExistingPlayers, occupant)
            print("Occupant added to existing party: " .. occupant.Name)
        end
    
        HandleParty(OrderOptions, PartyView, PlayerInput) 
    end
end

-- Add a Trove instance for managing connections
local controllerTrove = Trove.new()

-- Client Functions
function TableController:KnitStart()

    TableService = Knit.GetService("TableService")
    RankService = Knit.GetService("RankService")
    NotificationService = Knit.GetService("NotificationService")
    NavigationService = Knit.GetService("NavigationService")
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
    controllerTrove:Connect(TableUI.Close.Activated, function()
        uiOpen = false
        UIController:Close(TableUI)
    end)

    controllerTrove:Connect(Panel.Close.Activated, function()
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

            if UserInputService.TouchEnabled then
                -- mobile
                frame.Int.Position = UDim2.new(0.5, 0, 0.775, 0)
                frame.Title.Position = UDim2.new(0.5, 0, 0.71, 0)
                frame.SelectButton.Visible = true
            elseif not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
                -- laptop/desktop
                print('desktop')
                controllerTrove:Connect(frame.MouseEnter, function()
                    AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.5, 0, 0.775, 0)})
                    AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.5, 0, 0.71, 0)})
                    frame.SelectButton.Visible = true
                    AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.5, 0, 0.897, 0)}):AndThen(function()
                        frame.SelectButton.Visible = true
                    end)
                end)

                controllerTrove:Connect(frame.MouseLeave, function()
                    AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.494, 0, 0.877, 0)})
                    AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.494, 0, 0.94, 0)})
                    AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.494, 0, 1.147, 0)}):AndThen(function()
                        frame.SelectButton.Visible = false
                    end)
                end)
            elseif UserInputService.GamepadEnabled then
                -- console
                print('console')
                frame.SelectButton.Visible = true
                AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.5, 0, 0.775, 0)})
                AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.5, 0, 0.71, 0)})
                AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.5, 0, 0.897, 0)})
            elseif UserInputService.VREnabled then
                -- VR
                frame.SelectButton.Visible = true
                AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.5, 0, 0.775, 0)})
                AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.5, 0, 0.71, 0)})
                AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.5, 0, 0.897, 0)})
            end
            controllerTrove:Connect(frame.SelectButton.Activated, function()
                self:AreaSelected(frame.Name)
            end)

        end
    end

    for _, button in pairs(Panel:GetDescendants()) do
        if button:IsA("GuiButton") and button.Name ~= "Close" then
            local scaleFactor = UDim2.new(0.02, 0, 0.02, 0)
            local originalSize = button.Size

            controllerTrove:Connect(button.MouseEnter, function()
                AnimNation.target(button, {s = 20}, {Size = originalSize - scaleFactor})
            end)

            controllerTrove:Connect(button.MouseLeave, function()
                AnimNation.target(button, {s = 20}, {Size = originalSize})
            end)
        end
    end

    for _, button in pairs(Content:GetDescendants()) do
        if button:IsA("GuiButton") then
            local scaleFactor = UDim2.new(0.02, 0, 0.02, 0)
            local originalSize = button.Size

            controllerTrove:Connect(button.MouseEnter, function()
                AnimNation.target(button, {s = 20}, {Size = originalSize - scaleFactor})
            end)

            controllerTrove:Connect(button.MouseLeave, function()
                AnimNation.target(button, {s = 20}, {Size = originalSize})
            end)
        end
    end
end

function TableController:InitRegisters()
    local Functionality = workspace:WaitForChild("Functionality")
    local registers = Functionality:WaitForChild("Registers")

    RankService:Get():andThen(function(Rank)
        print("Rank fetched: " .. Rank)
        if Rank < 4 and not RunService:IsStudio() then
            for _, register in ipairs(registers:GetChildren()) do
                if register:FindFirstChild("Screen") and register.Screen:FindFirstChild("ProximityPrompt") then
                    register.Screen.ProximityPrompt:Destroy()
                end
            end
            return
        else
            for _, register in ipairs(registers:GetChildren()) do
                if register:FindFirstChild("Screen") and register.Screen:FindFirstChild("ProximityPrompt") then
                    controllerTrove:Connect(register.Screen.ProximityPrompt.Triggered, function()
                        print("ProximityPrompt triggered for register: " .. register.Name)
                        if currentTable == nil then
                            print("No table assigned to player")
                            -- ...existing code for when "Table" is nil...
                            selectedOption = 'New'
                            uiOpen = true
                            activeRegister = register
                            UIController:Open(TableUI)
                            TableService:TabletInit(register)
                        else
                            TableService:GetInfo(currentTable):andThen(function(tableData)
                                print(tableData)
                                if tableData then
                                    print("Table data fetched for table: " .. tableData.Name)
                                    selectedOption = 'Existing'
                                    uiOpen = true
                                    activeRegister = register
                                    TableService:TabletInit(register)

                                    local panelContent = Panel.Content
                                    panelContent.Section.Text = `Section: <b>{tableData.Category}</b>`
                                    panelContent.Title.Text = `Your party is assigned to Table <b>{tableData.Name}</b>`

                                    Panel.Content.Visible = true
                                    Panel.GuestSelection.Visible = false

                                    UIController:Open(Panel)

                                    -- Call PartyExists to handle occupants
                                    PartyExists(tableData) 
                                else
                                    warn("Failed to fetch table data")
                                end
                            end):catch(function(err)
                                warn("Error fetching table info: " .. tostring(err))
                            end)
                        end
                    end)

                    controllerTrove:Connect(register:GetAttributeChangedSignal("InUse"), function()
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

                    controllerTrove:Connect(Panel:GetPropertyChangedSignal("Visible"), checkUIVisibility)
                    controllerTrove:Connect(TableUI:GetPropertyChangedSignal("Visible"), checkUIVisibility)
                    controllerTrove:Connect(Content:GetPropertyChangedSignal("Visible"), function()

                        repeat task.wait() until UIController.FrameOpen

                        for _, frame in pairs(Content:GetChildren()) do
                            if UserInputService.TouchEnabled or UserInputService.GamepadEnabled or UserInputService.VREnabled then
                                -- mobile, console, vr
                                if frame:IsA("Frame") then
                                    AnimNation.target(frame.Int, {s = 8}, {Position = UDim2.new(0.5, 0, 0.775, 0)})
                                    AnimNation.target(frame.Title, {s = 8}, {Position = UDim2.new(0.5, 0, 0.71, 0)})
                                    frame.SelectButton.Visible = true
                                    AnimNation.target(frame.SelectButton, {s = 8}, {Position = UDim2.new(0.5, 0, 0.897, 0)}):AndThen(function()
                                        frame.SelectButton.Visible = true
                                    end)
                                end
                            end
                        end
                end)
                end
            end
        end
    end):catch(function(err)
        warn("Error fetching rank: " .. tostring(err))
    end)
end

function TableController:AreaSelected(Area: string)
    ResetPartyData(true) -- Reset global variables

    UIController:Close(TableUI)
    UIController:Open(Panel)

    local GuestSelection = Panel:WaitForChild("GuestSelection")
    local panelContent = Panel.Content

    GuestSelection.Section.Text = `Section: <b>{Area}</b>`

    GuestSelection.OrderOptions.GuestInput.TextLabel.Text = ""

    local originalSize = GuestSelection.OrderOptions.Confirm.Size

    local trove = Trove.new() -- Create a new Trove instance to manage connections

    trove:Connect(GuestSelection.OrderOptions.Confirm.MouseEnter, function()
        local scaleFactor = UDim2.new(0.02, 0, 0.02, 0)
        AnimNation.target(GuestSelection.OrderOptions.Confirm, {s = 20}, {Size = originalSize - scaleFactor})
    end)

    trove:Connect(GuestSelection.OrderOptions.Confirm.MouseLeave, function()
        AnimNation.target(GuestSelection.OrderOptions.Confirm, {s = 20}, {Size = originalSize})
    end)

    local function NewParty()
        local panelContent = Panel.Content
        local OrderOptions = panelContent:WaitForChild("OrderOptions")
        local PartyView = panelContent:WaitForChild("PartyView")
        local PlayerInput = OrderOptions.PlayerInput.TextLabel

        HandleParty(OrderOptions, PartyView, PlayerInput)
    end

    trove:Connect(GuestSelection.OrderOptions.Confirm.Activated, function()
        local Guests = GuestSelection.OrderOptions.GuestInput.TextLabel.Text

        if Guests == "" or tonumber(Guests) == nil or tonumber(Guests) > 9 or tonumber(Guests) < 1 then
            GuestSelection.OrderOptions.GuestInput.TextLabel.Text = ""
            GuestSelection.OrderOptions.GuestInput.TextLabel.PlaceholderText = "Invalid Entry"

            task.delay(2, function()
                GuestSelection.OrderOptions.GuestInput.TextLabel.PlaceholderText = "# of Guests"
            end)

            return
        end

        TableService:Claim(Area, tonumber(Guests)):andThen(function(success, tableData)
            if not success then return end

            currentTable = tableData.Table

            local Name = string.match(tableData.Name, "%d+")
            local Occupants = tableData.Occupants or {}

            panelContent.Section.Text = `Section: <b>{tableData.Category}</b>`
            panelContent.Title.Text = `Your party is assigned to Table <b>{Name}</b>`

            GuestSelection.Visible = false
            panelContent.Visible = true       

            if #Occupants > 0 then
                PartyExists(tableData)
                selectedOption = 'Existing'
            else
                NewParty()
                selectedOption = 'New'
            end

            --[[ TODO:
                - Submit logic that handles different cases
            ]]
            panelContent.OrderOptions.Confirm.Activated:Connect(function()

                if #PlayersToAdd == 0 then
                    NotificationService:CreateNotif(Player, "Please add at least one player to your party.")
                    return
                end

                if selectedOption == 'New' then
                    TableService:SetOccupied(currentTable, PlayersToAdd):andThen(function(success)
                        if success then
                            NavigationService:Beam(tableData.Table):andThen(function(success)
                                if success then
                                    UIController:Close(Panel)
                                    TableService:TabletEnd(activeRegister)
                                    activeRegister = nil
                                    NotificationService:CreateNotif(Player, `Please take your guests to Table <b>{Name}</b> using the arrows.`)

                                    for _, occupant in pairs(PlayersToAdd) do
                                        if occupant:IsA("Player") then
                                            NotificationService:CreateNotif(occupant, `Please follow your server to Table <b>{Name}</b>.`)
                                        end
                                    end

                                end
                            end):catch(function(err)
                                warn("Error: ", err)
                            end)
                            -- add server path logic here
                        end
                    end)
                end
            end)
        end)
    end)

    trove:Connect(panelContent.OrderOptions.Vacate.Activated, function()
        if not currentTable then
            NotificationService:CreateNotif(Player, "No table is currently assigned to vacate.")
            return
        end
    
        TableService:SetUnoccupied(currentTable):andThen(function(success)
            if success then
                -- Reset UI & data
                ResetPartyData(true)
    
                -- End tablet session if active
                if activeRegister then
                    TableService:TabletEnd(activeRegister)
                    activeRegister = nil
                end
    
                NotificationService:CreateNotif(Player, "You have successfully vacated the table.")
            else
                NotificationService:CreateNotif(Player, "Failed to vacate the table. Please try again.")
            end
        end):catch(function(err)
            warn("Error while vacating table: " .. tostring(err))
            NotificationService:CreateNotif(Player, "An error occurred while vacating the table.")
        end)
    end)
    
    -- Cleanup connections when UI is closed
    controllerTrove:Connect(Panel:GetPropertyChangedSignal("Visible"), function()
        if not Panel.Visible then
            trove:Clean()
        end
    end)
end

-- Cleanup Trove when the controller is destroyed
function TableController:Destroy()
    controllerTrove:Clean()
end

-- Return Controller to Knit.
return TableController
