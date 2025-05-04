--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove)

-- Create Knit Controller
local OrderController = Knit.CreateController {
    Name = "OrderController",
    SelectionBoxes = {},
    ClickDetectors = {},
    Trove = Trove.new(),
    SelectionActive = false
}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")

local CreateOrder: ImageButton = GochiUI:WaitForChild("CreateOrder")
local ChefQueue: ImageButton = GochiUI:WaitForChild("ChefQueue")
local OrderCreation: Frame = GochiUI:WaitForChild("OrderCreation")
local Buttons: Frame = OrderCreation:WaitForChild('Content'):WaitForChild('Buttons')
local Pages: Frame = OrderCreation:WaitForChild('Content'):WaitForChild('MainContent')
local Queue: Frame = GochiUI:WaitForChild("Queue")

local OrderBoard: SurfaceGui = PlayerGui:WaitForChild("SurfaceUIs"):WaitForChild("OrderBoard")

local OrderService, TableService, NotificationService
local UIController

local queueUIEntries: table = {}
local orderUIEntries: table = {}

local timerRunning: boolean = false
local orderTimer: boolean = false

function OrderController:ClearSelections()
    self.Trove:Clean()
    self.SelectionBoxes = {}
    self.ClickDetectors = {}
end

function OrderController:KnitStart()
    OrderService = Knit.GetService("OrderService")
    TableService = Knit.GetService("TableService")
    NotificationService = Knit.GetService("NotificationService")
    UIController = Knit.GetController("UIController")

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

    OrderService.OrderCompleted:Connect(function(orderDetails: table): nil
        local orderEntry = orderUIEntries[orderDetails.OrderId]

        if not orderEntry then
            warn("Order entry not found for orderId:", orderDetails.OrderId)
            return
        end

        orderEntry.Frame.ClaimButton.Visible = true

        local claimConn = orderEntry.Frame.ClaimButton.Activated:Connect(function()
            OrderService:ClaimOrder(orderDetails.OrderId):andThen(function(success, errorMessage)
                if success then
                    NotificationService:CreateNotif(Player, `Order claimed successfully! Please deliver it to <b>{orderDetails.Player.Name}</b>.`)
                else
                    NotificationService:CreateNotif(Player, errorMessage or `Failed to claim order. Error: {errorMessage}`)
                end
            end)
        end)

        self.Trove:Add(claimConn)
    end)
end

OrderController.UpdateQueue = function(queueInfo: table): nil
    for _, child in ipairs(Queue.ScrollingFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    queueUIEntries = {}

    local function CreatePlayer(chefId, time, position)
        local chef = Players:GetPlayerByUserId(chefId)
        if not chef then return end
        assert(time and type(time) == "number", "Expected a valid join time")

        local Template = Queue.Template:Clone()
        Template.Parent = Queue.ScrollingFrame

        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content = Players:GetUserThumbnailAsync(chef.UserId, thumbType, thumbSize)

        Template:WaitForChild("ProfileBase").Headshot.Image = content
        Template.Username.Text = chef.Name
        Template.Title.Text = `#{position}`
        Template.Time.Text = "00:00 in queue"
        Template.Visible = true

        queueUIEntries[chef.UserId] = {
            Frame = Template,
            JoinTime = time,
        }
    end

    local position = 1
    for _, entry in ipairs(queueInfo.priority) do
        CreatePlayer(entry.UserId, entry.JoinTime, position)
        position += 1
    end

    for _, entry in ipairs(queueInfo.normal) do
        CreatePlayer(entry.UserId, entry.JoinTime, position)
        position += 1
    end

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

OrderController.UpdateOrders = function(orderDetails: table): nil
    if not orderDetails or not orderDetails.OrderId then
        warn("Invalid order details received")
        return
    end

    if orderUIEntries[orderDetails.OrderId] then
        local existingOrder = orderUIEntries[orderDetails.OrderId]

        if orderDetails.Action == "CompleteItem" then
            local itemLabel = existingOrder.Frame.Items:FindFirstChild(orderDetails.ItemName)
            if itemLabel then
                itemLabel.Text = `✅ {orderDetails.ItemName}`
            else
                warn(`Item label not found for {orderDetails.ItemName} in existing order`)
            end
        elseif orderDetails.Action == "CompleteOrder" or orderDetails.Action == "CancelOrder" then
            existingOrder.Frame:Destroy()
            orderUIEntries[orderDetails.OrderId] = nil
        else
            warn(`Unknown action {orderDetails.Action} for order {orderDetails.OrderId}`)
        end
        return
    end

    local Template = OrderBoard.OrderTemplate
    if not Template then return warn("OrderBoard.OrderTemplate not found") end

    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420

    local clone = Template:Clone()
    clone.Name = `Order_{orderDetails.OrderId}`
    clone.TableNumber.Text = `Table {string.match(orderDetails.Table, "%d+")}`
    clone.Server.Text = orderDetails.Server.Name
    clone.Server_Thumbnail.Image = Players:GetUserThumbnailAsync(orderDetails.Server.UserId, thumbType, thumbSize)
    clone.OrderedPlayer.Image = Players:GetUserThumbnailAsync(orderDetails.Player.UserId, thumbType, thumbSize)
    clone.Title.Text = orderDetails.Player.Name
    clone.TimeElapsed.Text = "00:00"

    for index, item in ipairs(orderDetails.Items) do
        local itemLabel = clone.Items:FindFirstChild("Item_" .. tostring(index))
        if itemLabel then
            itemLabel.Name = item
            itemLabel.Text = `❌ {item}`
            itemLabel.Visible = true
        else
            warn(`Item label not found for index {index} in order template`)
        end
    end

    clone.Parent = OrderBoard.Frame.ScrollingFrame
    clone.Visible = true

    orderUIEntries[orderDetails.OrderId] = {
        Frame = clone,
        OrderDetails = orderDetails,
    }

    if not orderTimer then
        orderTimer = true
        task.spawn(function()
            while true do
                local now = os.time()
                for orderId, data in pairs(orderUIEntries) do
                    local elapsed = now - data.OrderDetails.Time
                    data.Frame.TimeElapsed.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
                end
                task.wait(1)
            end
        end)
    end

    clone.CancelButton.Activated:Connect(function()
        OrderService:CancelOrder(orderDetails.OrderId):andThen(function(success, errorMessage)
            if success then
                NotificationService:CreateNotif(Player, `Order #{orderDetails.OrderId} has been cancelled.`)
                orderUIEntries[orderDetails.OrderId].Frame:Destroy()
                orderUIEntries[orderDetails.OrderId] = nil
            else
                NotificationService:CreateNotif(Player, errorMessage or `Failed to cancel order. Error: {errorMessage}`)
            end
        end):catch(function(err)
            warn("Error cancelling order:", err)
            NotificationService:CreateNotif(Player, 'An error occurred while trying to cancel the order.')
        end)
    end)
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

                self:ClearSelections()
                local SelectionTrove = Trove.new()
                self.Trove:Add(SelectionTrove)

                for _, Occupant in Occupants do
                    local Character = Occupant.Character or Occupant.CharacterAdded:Wait()

                    local SelectionBox = Instance.new("SelectionBox")
                    SelectionBox.Adornee = Character
                    SelectionBox.Color3 = Color3.fromHex('ab1eff')
                    SelectionBox.SurfaceColor3 = Color3.fromRGB(123, 22, 186)
                    SelectionBox.LineThickness = 0.05
                    SelectionBox.SurfaceTransparency = 0.5
                    SelectionBox.Parent = Character

                    SelectionTrove:Add(SelectionBox)
                    table.insert(self.SelectionBoxes, SelectionBox)

                    local ClickDetector = Instance.new("ClickDetector")
                    ClickDetector.MaxActivationDistance = 20
                    ClickDetector.Parent = Character

                    SelectionTrove:Add(ClickDetector)
                    table.insert(self.ClickDetectors, ClickDetector)

                    local mouseClickConn = ClickDetector.MouseClick:Connect(function()
                        local OrderTrove = Trove.new()
                        self.Trove:Add(OrderTrove)

                        local toSubmit: {string} = {}
                        self:ClearSelections()

                        local Table = Player:GetAttribute('Table')
                        local thumbType = Enum.ThumbnailType.HeadShot
                        local thumbSize = Enum.ThumbnailSize.Size420x420
                        local content = Players:GetUserThumbnailAsync(Occupant.UserId, thumbType, thumbSize)

                        OrderCreation.Content.PlayersInParty.ProfileBase.Headshot.Image = content
                        OrderCreation.Content.PlayersInParty.Username.Text = Occupant.Name
                        UIController:Open(OrderCreation)

                        local OrderContentHolder = OrderCreation.Content.OrderContent.OrderContentHolder
                        for _, child in ipairs(OrderContentHolder:GetChildren()) do
                            if not child:IsA("UIListLayout") then
                                child:Destroy()
                            end
                        end

                        OrderTrove:Add(OrderCreation.Close.Activated:Connect(function()
                            UIController:Close(OrderCreation)
                        end))

                        OrderTrove:Add(OrderCreation.Content.OrderOptions.Confirm.Activated:Connect(function()
                            if #toSubmit > 0 then
                                OrderService:Submit({
                                    Player = {
                                        Occupant = Occupant,
                                        Headshot = content,
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
                        end))

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
                                        OrderTrove:Add(buttonConn)
                                    end
                                end
                            end
                        end
                    end)

                    SelectionTrove:Add(mouseClickConn)
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

    Player:GetAttributeChangedSignal("OrderId"):Connect(function()
        if Player:GetAttribute("OrderId") ~= nil then
            Queue.Join.TextLabel.Text = 'Leave queue'
        else
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

return OrderController
