--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local RunService = game:GetService('RunService')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) -- @module Knit

local AnimNation = require(Knit.Modules.AnimNation) -- @module AnimNation
local Trove = require(ReplicatedStorage.Packages.Trove) -- @module Trove

-- Create Knit Controller
local OrderController = Knit.CreateController {
    Name = "OrderController",
    SelectionBoxes = {},
    ClickDetectors = {},
    Trove = Trove.new(),
    SelectionActive = false
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")

local CreateOrder = GochiUI:WaitForChild("CreateOrder") -- @type ImageButton
local ChefQueue = GochiUI:WaitForChild("ChefQueue") -- @type ImageButton

local OrderCreation = GochiUI:WaitForChild("OrderCreation") -- @type Frame
local Buttons = OrderCreation:WaitForChild('Content'):WaitForChild('Buttons') -- @type Frame
local Pages = OrderCreation:WaitForChild('Content'):WaitForChild('MainContent') -- @type Frame

local Queue = GochiUI:WaitForChild("Queue") -- @type Frame

local OrderBoard = PlayerGui:WaitForChild("SurfaceUIs"):WaitForChild("OrderBoard") -- @type SurfaceGui

local OrderService
local TableService
local NotificationService

local UIController

local queueUIEntries = {} -- [UserId] = { Frame = Template, JoinTime = time }
local orderUIEntries = {} -- [OrderId] = { Frame = Template, OrderDetails = orderDetails }

-- Helper to clean up previous visuals
function OrderController:ClearSelections()
    self.Trove:Clean() -- Automatically destroys all previous SelectionBoxes and ClickDetectors
    self.SelectionBoxes = {}
    self.ClickDetectors = {}
end

-- Client Functions
function OrderController:KnitStart()
    OrderService = Knit.GetService("OrderService") -- @module OrderService
    TableService = Knit.GetService("TableService") -- @module TableService
    NotificationService = Knit.GetService("NotificationService") -- @module NotificationService
    UIController = Knit.GetController("UIController") -- @module UIController

    for _, button in pairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            button.Activated:Connect(function()
                self:SetState(button)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    OrderCreation.Close.Activated:Connect(function()
        UIController:Close(OrderCreation)
    end)

    Queue.Close.Activated:Connect(function()
        UIController:Close(Queue)
    end)

    self:InitOrders()
    self:InitChefQueue()

    OrderService.UpdateQueue:Connect(self.UpdateQueue)
    OrderService.UpdateOrder:Connect(self.UpdateOrders)
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local queueUIEntries = {} -- Tracks current UI entries
local timerRunning = false

OrderController.UpdateQueue = function(queueInfo: table): nil
    -- Clear old UI elements
    for _, child in ipairs(Queue.ScrollingFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    -- Reset tracking
    queueUIEntries = {}

    -- Create UI entry for each player
    local function CreatePlayer(chefId, time, position)
        local chef = Players:GetPlayerByUserId(chefId)
        if not chef then return end
        assert(time and type(time) == "number", "Expected a valid join time")

        local Template = Queue.Template:Clone()
        Template.Parent = Queue.ScrollingFrame

        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content = Players:GetUserThumbnailAsync(chef.UserId, thumbType, thumbSize)

        Template.ProfileBase.Headshot.Image = content
        Template.Username.Text = chef.Name
        Template.Title.Text = `#{position}` -- Set position here
        Template.Time.Text = "00:00 in queue"
        Template.Visible = true

        queueUIEntries[chef.UserId] = {
            Frame = Template,
            JoinTime = time,
        }
    end

    -- Add entries in order
    local position = 1
    for _, entry in ipairs(queueInfo.priority) do
        CreatePlayer(entry.UserId, entry.JoinTime, position)
        position += 1
    end

    for _, entry in ipairs(queueInfo.normal) do
        CreatePlayer(entry.UserId, entry.JoinTime, position)
        position += 1
    end

    -- Start or maintain a single timer loop
    if not timerRunning then
        timerRunning = true
        task.spawn(function()
            while true do
                local now = os.time()
                for userId, data in pairs(queueUIEntries) do
                    local elapsed = now - data.JoinTime
                    data.Frame.Time.Text = string.format("%02d:%02d in queue", math.floor(elapsed / 60), elapsed % 60)
                end
                task.wait(1)
            end
        end)
    end
end

local orderTimer = false
OrderController.UpdateOrders = function(orderDetails: table): nil
    warn(orderDetails)
    local Template = OrderBoard.OrderTemplate -- @type Frame

    if not Template then
        warn("OrderBoard.OrderTemplate not found")
        return
    end

    if not orderDetails or type(orderDetails) ~= "table" then
        warn("Invalid order details received")
        return
    end

    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420

    local clone = Template:Clone()
    clone.Name = `Order_{orderDetails.OrderId}`
    clone.TableNumber.Text = `Table {string.match(orderDetails.Table, "%d+")}` -- Display the table number
    clone.Server.Text = orderDetails.Server.Name
    clone.Server_Thumbnail.Image = Players:GetUserThumbnailAsync(orderDetails.Server.UserId, thumbType, thumbSize)
    clone.OrderedPlayer.Image = orderDetails.Player.Headshot or "" -- Fallback to empty string if no headshot is provided
    clone.Title.Text = orderDetails.Player.Occupant.Name -- Display the name of the player who made the order
    clone.TimeElapsed.Text = "00:00" -- Placeholder, will be updated by timer

    for index, item in ipairs(orderDetails.Items) do
        -- Create an entry for each item in the order
        local itemLabel = clone.Items:FindFirstChild("Item_" .. tostring(index)) -- Assuming Item1, Item2, etc. in the template
        if itemLabel then
            itemLabel.Text = `❌ {item}` -- Set the text to the item name
            itemLabel.Visible = true -- Ensure it's visible
        else
            warn(`Item label not found for index {index} in order template`)
        end
    end

    clone.Parent = OrderBoard.Frame.ScrollingFrame
    clone.Visible = true

    if not orderDetails.OrderId then
        warn("OrderId is missing in orderDetails")
        return
    end

    orderUIEntries[orderDetails.OrderId] = {
        Frame = clone,
        OrderDetails = orderDetails, -- Store the order details for future reference
    }

    if not orderTimer then
        orderTimer = true
        task.spawn(function()
            while true do
                local now = os.time()
                for orderId, data in pairs(orderUIEntries) do
                    local elapsed = now - data.OrderDetails.Time -- Use the time the order was created to calculate elapsed time
                    data.Frame.TimeElapsed.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
                end
                task.wait(1)
            end
        end)
    end
end

function OrderController:InitOrders()
    CreateOrder.Activated:Connect(function()

        if self.SelectionActive then
            self:ClearSelections()
            self.SelectionActive = false
            return
        end

        if Player:GetAttribute('Table') ~= nil and Player:GetAttribute("Server") then
            TableService:GetOccupants(Player:GetAttribute('Table')):andThen(function(Occupants)
                if #Occupants <= 0 then
                    return NotificationService:CreateNotif(Player, 'Your party has no occupants to serve.')
                end

                self:ClearSelections() -- Clear existing selection visuals before creating new ones

                for _, Occupant in Occupants do
                    local Character = Occupant.Character or Occupant.CharacterAdded:Wait()

                    local SelectionBox = Instance.new("SelectionBox")
                    SelectionBox.Adornee = Character
                    SelectionBox.Color3 = Color3.fromHex('ab1eff')
                    SelectionBox.SurfaceColor3 = Color3.fromRGB(123, 22, 186)
                    SelectionBox.LineThickness = 0.05
                    SelectionBox.SurfaceTransparency = 0.5
                    SelectionBox.Parent = Character

                    self.Trove:Add(SelectionBox)
                    table.insert(self.SelectionBoxes, SelectionBox)

                    local ClickDetector = Instance.new("ClickDetector")
                    ClickDetector.MaxActivationDistance = 20
                    ClickDetector.Parent = Character

                    self.Trove:Add(ClickDetector)
                    table.insert(self.ClickDetectors, ClickDetector)

                    local mouseClickConn = ClickDetector.MouseClick:Connect(function()

                        local toSubmit: {string} = {}

                        self:ClearSelections()

                        local Table = Player:GetAttribute('Table')

                        local thumbType = Enum.ThumbnailType.HeadShot
                        local thumbSize = Enum.ThumbnailSize.Size420x420
                        local content, isReady = Players:GetUserThumbnailAsync(Occupant.UserId, thumbType, thumbSize)

                        OrderCreation.Content.PlayersInParty.ProfileBase.Headshot.Image = content
                        OrderCreation.Content.PlayersInParty.Username.Text = Occupant.Name

                        UIController:Open(OrderCreation)

                        -- Clear previous order content but preserve UIListLayout
                        local OrderContentHolder = OrderCreation.Content.OrderContent.OrderContentHolder
                        for _, child in ipairs(OrderContentHolder:GetChildren()) do
                            if not child:IsA("UIListLayout") then
                                child:Destroy()
                            end
                        end

                        local closeConn = OrderCreation.Close.Activated:Connect(function()
                            UIController:Close(OrderCreation)
                        end)
                        self.Trove:Add(closeConn)

                        local confirmConn = OrderCreation.Content.OrderOptions.Confirm.Activated:Connect(function()
                            if #toSubmit > 0 then
                                OrderService:Submit({
                                    Player = {
                                        Occupant = Occupant, -- @type Player
                                        Headshot = content, -- @type string (URL to the thumbnail)
                                    },
                                    Table = Table,
                                    Items = toSubmit
                                }):andThen(function(success)
                                    if success then
                                        NotificationService:CreateNotif(Player, `Order submitted successfully for {Occupant.Name}!`)
                                        UIController:Close(OrderCreation)
                                    else
                                        NotificationService:CreateNotif(Player, 'Failed to submit order. Please try again later.')
                                    end
                                end):catch(function(err)
                                    warn("Error submitting order:", err)
                                    NotificationService:CreateNotif(Player, 'An error occurred while submitting the order.')
                                end)
                            else
                                return NotificationService:CreateNotif(Player, 'You must submit atleast one item to create an order.')
                            end
                        end)
                        self.Trove:Add(confirmConn)

                        for _, page in pairs(OrderCreation.Content.MainContent:GetChildren()) do
                            if page:IsA("ScrollingFrame") then
                                for _, button in pairs(page:GetChildren()) do
                                    if button:IsA("GuiButton") then
                                        local buttonConn = button.Activated:Connect(function()
                                            print('Button clicked:', button.Name)

                                            if #toSubmit >= 3 then
                                                return NotificationService:CreateNotif(Player, 'You can only submit 3 items per player.')
                                            end

                                            local item = button.Name

                                            local OrderContent = OrderCreation.Content.OrderContent
                                            local Template = OrderContent.Template

                                            local Clone = Template:Clone()
                                            Clone.Name = item
                                            Clone.Text = item

                                            Clone.Visible = true
                                            Clone.Parent = OrderContent.OrderContentHolder

                                            table.insert(toSubmit, item)
                                        end)
                                        self.Trove:Add(buttonConn)
                                    end
                                end
                            end
                        end

                    end)
                    self.Trove:Add(mouseClickConn)
                end
            end)
        else
            NotificationService:CreateNotif(Player, 'You need to serve a party to create an order!')
        end
    end)
end

function OrderController:InitChefQueue()
    ChefQueue.Activated:Connect(function()
        UIController:Open(Queue)
    end)

    OrderService.UpdateUI:Connect(function(action)
        if action == 'LeaveQueue' then
            Queue.Join.TextLabel.Text = 'Join queue'
        end
    end)

    Queue.Join.Activated:Connect(function()

        if Queue.Join.TextLabel.Text == 'Join queue' then
            OrderService:JoinQueue():andThen(function(success)
                if success then
                    NotificationService:CreateNotif(Player, 'You have successfully joined the chef queue!')
                    Queue.Join.TextLabel.Text = 'Leave queue'
                else
                    NotificationService:CreateNotif(Player, 'Failed to join the chef queue. Please try again later.')
                end
            end):catch(function(err)
                warn("Error joining queue:", err)
                NotificationService:CreateNotif(Player, 'An error occurred while trying to join the chef queue.')
            end)
        elseif Queue.Join.TextLabel.Text == 'Leave queue' then
            OrderService:LeaveQueue():andThen(function(success)
                if success then
                    NotificationService:CreateNotif(Player, 'You have successfully left the chef queue!')
                    UIController:Close(Queue)
                    Queue.Join.TextLabel.Text = 'Join queue'
                else
                    NotificationService:CreateNotif(Player, 'Failed to leave the chef queue. Please try again later.')
                end
            end):catch(function(err)
                warn("Error leaving queue:", err)
                NotificationService:CreateNotif(Player, 'An error occurred while trying to leave the chef queue.')
            end)
        end
    end)
end

function OrderController:SetState(selectedButton: ImageButton)
    assert(selectedButton:IsA("ImageButton"), "Button must be an ImageButton")

    for _, button in ipairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            local isSelected = button == selectedButton

            AnimNation.target(button, {s = 10}, {ImageTransparency = isSelected and 0 or 1})
            AnimNation.target(button.TextLabel, {s = 10}, {TextColor3 = isSelected and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 255, 255)})
        end
    end
end

function OrderController:OpenPage(Page: ScrollingFrame | Frame)
    for _, page in ipairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") or page:IsA("Frame") then
            page.Visible = page == Page
        end
    end
end

-- Return Controller to Knit
return OrderController
