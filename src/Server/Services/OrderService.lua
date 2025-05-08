--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage: ServerStorage = game:GetService("ServerStorage")
local HttpService: HttpService = game:GetService("HttpService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove)

-- Structures
local Queue: ModuleScript = require(Knit.Structures.Queue)
local HashSet: ModuleScript = require(Knit.Structures.HashSet)

-- Create Knit Service
local OrderService = Knit.CreateService {
    Name = "OrderService",
    Client = {
        UpdateQueue = Knit.CreateSignal(),
        UpdateOrder = Knit.CreateSignal(),
        OrderCompleted = Knit.CreateSignal(),
        ItemCompleted = Knit.CreateSignal(),
        UpdateUI = Knit.CreateSignal(),
    },
}

-- Internal Structures
local priorityQueue = Queue.new()
local normalQueue = Queue.new()
local queuedUserIds = HashSet.new()
local joinTimes = {}

-- Active Orders
local activeOrders: table = {}
local retryQueue = {} -- For fallback
local orderTroves = {} -- Trove cleanup for orders

-- Variables
local KitchenService, NavigationService, RankService, NotificationService

local function rebuildQueueExcluding(queue, excludeUserId)
    local newQueue = Queue.new()
    while not queue:isEmpty() do
        local userId = queue:pop()
        if userId ~= excludeUserId then
            newQueue:push(userId)
        end
    end
    return newQueue
end

local function queueToTableWithJoinTimes(queue)
    local result = {}
    local tempQueue = Queue.new()
    while not queue:isEmpty() do
        local userId = queue:pop()
        tempQueue:push(userId)
        table.insert(result, {
            UserId = userId,
            JoinTime = joinTimes[userId] or os.time(),
        })
    end
    while not tempQueue:isEmpty() do
        queue:push(tempQueue:pop())
    end
    return result
end

local function broadcastQueueUpdate(self)
    self.Client.UpdateQueue:FireAll({
        priority = queueToTableWithJoinTimes(priorityQueue),
        normal = queueToTableWithJoinTimes(normalQueue),
    })
end

local function isOrderComplete(orderData)
    for i = 1, #orderData.Items do
        if not orderData.Completed[i] then
            return false
        end
    end
    return true
end

local function tryAssignPendingOrders(self)
    for orderId, orderData in pairs(activeOrders) do
        for index, item in ipairs(orderData.Items) do
            if not orderData.Completed[index] and not orderData.Assignments[index] then
                local chef = self:PeekNextPlayer()
                if chef then
                    chef = self:PopNextPlayer()
                    if chef then
                        orderData.Assignments[index] = chef
                        KitchenService:SelectItem(chef, item)
                        chef:SetAttribute("OrderId", orderId)

                        self.Client.UpdateOrder:FireAll({
                            OrderId = orderId,
                            Action = "AssignItem",
                            Index = index,
                            Chef = chef,
                            Item = item,
                        })
                        broadcastQueueUpdate(self)
                    end
                else
                    table.insert(retryQueue, {
                        OrderId = orderId,
                        Index = index,
                        Item = item,
                    })
                end
            end
        end
    end
end

function OrderService:_submit(server: Player, orderDetails: table): boolean
    assert(server:IsA("Player"))
    assert(type(orderDetails) == "table")
    assert(server:GetAttribute("Table") and server:GetAttribute("Server"))
    assert(orderDetails.Player and orderDetails.Table and orderDetails.Items)

    local orderId = HttpService:GenerateGUID(false)
    orderDetails.OrderId = orderId

    activeOrders[orderId] = {
        Player = orderDetails.Player,
        Server = server,
        Table = orderDetails.Table,
        Items = orderDetails.Items,
        Assignments = {},
        Completed = {},
    }

    orderTroves[orderId] = Trove.new()

    tryAssignPendingOrders(self)
    broadcastQueueUpdate(self)

    self.Client.UpdateOrder:FireAll({
        OrderId = orderId,
        Server = server,
        Player = orderDetails.Player,
        Action = "NewOrder",
        Table = orderDetails.Table,
        Items = orderDetails.Items,
        Assignments = {},
        Time = os.time(),
    })

    return true
end

function OrderService:_markItemDone(chef: Player, orderId: string, itemName: string): boolean
    local orderData = activeOrders[orderId]
    if not orderData then return false end

    local foundIndex
    for index, assignedChef in ipairs(orderData.Assignments) do
        if assignedChef == chef and orderData.Items[index] == itemName and not orderData.Completed[index] then
            foundIndex = index
            break
        end
    end

    if not foundIndex then return false end
    orderData.Completed[foundIndex] = true

    if isOrderComplete(orderData) then
        self.Client.OrderCompleted:Fire(orderData.Server, {
            OrderId = orderId,
            Table = orderData.Table,
            Player = orderData.Player,
        })
        NotificationService:_createNotif(orderData.Server, `Order for <b>{orderData.Player.Name}</b> is ready!`)
    end

    self.Client.UpdateOrder:FireAll({
        OrderId = orderId,
        ItemName = itemName,
        Action = "CompleteItem",
    })

    chef:SetAttribute("OrderId", nil)
    tryAssignPendingOrders(self)

    return true
end

function OrderService:_claimOrder(Server: Player, orderId: string)
    local orderData = activeOrders[orderId]
    if not orderData then return false end

    if orderData.Server ~= Server then return false, `You are not the server for order #{orderId}` end
    if not Players:GetPlayerByUserId(orderData.Player.UserId) then return false, "The player who placed the order is not in the server" end

    for index, item in ipairs(orderData.Items) do
        if not orderData.Completed[index] then
            return false, "Not all items are completed"
        end

        local itemClone = ServerStorage.Food[item]:Clone()
        if itemClone then
            itemClone.Parent = Server.Backpack
        else
            return false, `Item {item} not found in ServerStorage`
        end
    end

    self.Client.UpdateOrder:FireAll({
        OrderId = orderId,
        Action = "CompleteOrder",
    })

    local success = NavigationService:InitBeam(Server, orderData.Player.Character)
    if not success then
        return false, "Failed to initialize beam to the player"
    end

    if orderTroves[orderId] then
        orderTroves[orderId]:Clean()
        orderTroves[orderId] = nil
    end

    activeOrders[orderId] = nil
    return true, "Order completed successfully"
end

function OrderService:_cancelOrder(Player: Player, orderId: string)
    local orderData = activeOrders[orderId]
    if not orderData then
        return false, "Order does not exist."
    end

    if Player ~= Players:GetPlayerByUserId(orderData.Server.UserId) or not Player:GetAttribute("Staff") then
        return false, "You do not have permission to cancel this order."
    end

    -- Clear assigned chefs
    for _, chef in pairs(orderData.Assignments) do
        if chef and chef:IsA("Player") then
            chef:SetAttribute("OrderId", nil)
        end
    end

    -- Remove from retry queue
    local newRetryQueue = {}
    for _, pending in ipairs(retryQueue) do
        if pending.OrderId ~= orderId then
            table.insert(newRetryQueue, pending)
        end
    end
    retryQueue = newRetryQueue

    -- Cleanup trove
    if orderTroves[orderId] then
        orderTroves[orderId]:Clean()
        orderTroves[orderId] = nil
    end

    -- Remove order
    activeOrders[orderId] = nil

    self.Client.UpdateOrder:FireAll({
        OrderId = orderId,
        Action = "CancelOrder",
    })

    broadcastQueueUpdate(self)

    return true, "Order cancelled successfully."
end

function OrderService:_joinQueue(Player: Player, Purchased: boolean?): boolean
    local userId = Player.UserId
    if queuedUserIds:contains(userId) then return false end

    if Purchased then
        priorityQueue:push(userId)
    else
        normalQueue:push(userId)
    end

    joinTimes[userId] = os.time()
    queuedUserIds:add(userId)
    broadcastQueueUpdate(self)
    tryAssignPendingOrders(self)

    return true
end

function OrderService:_leaveQueue(Player: Player): boolean
    local userId = Player.UserId
    if not queuedUserIds:contains(userId) then return false end

    priorityQueue = rebuildQueueExcluding(priorityQueue, userId)
    normalQueue = rebuildQueueExcluding(normalQueue, userId)
    queuedUserIds:remove(userId)
    joinTimes[userId] = nil
    broadcastQueueUpdate(self)
    self.Client.UpdateUI:Fire(Player, { Action = "LeaveQueue" })

    return true
end

function OrderService:PeekNextPlayer(): Player?
    local userId
    if not priorityQueue:isEmpty() then
        userId = priorityQueue:peek()
    elseif not normalQueue:isEmpty() then
        userId = normalQueue:peek()
    end

    if userId then
        return Players:GetPlayerByUserId(userId)
    end
    return nil
end

function OrderService:PopNextPlayer(): Player?
    local userId
    if not priorityQueue:isEmpty() then
        userId = priorityQueue:pop()
    elseif not normalQueue:isEmpty() then
        userId = normalQueue:pop()
    end

    if userId then
        queuedUserIds:remove(userId)
        joinTimes[userId] = nil
        local player = Players:GetPlayerByUserId(userId)
        if not player then
            warn("Player with userId " .. tostring(userId) .. " not found in the game.")
        end
        return player
    end
    return nil
end

function OrderService:KnitStart()
    KitchenService = Knit.GetService("KitchenService")
    NavigationService = Knit.GetService("NavigationService")
    RankService = Knit.GetService("RankService")
    NotificationService = Knit.GetService("NotificationService")

    Players.PlayerRemoving:Connect(function(player)
        self:_leaveQueue(player)
    
        -- Check if this player is involved in any active orders (as Server or Player)
        for orderId, orderData in pairs(activeOrders) do
            local isServerLeaving = orderData.Server == player
            local isOrderingPlayerLeaving = orderData.Player == player
    
            if isServerLeaving or isOrderingPlayerLeaving then
                -- Clean up the order
                if orderTroves[orderId] then
                    orderTroves[orderId]:Clean()
                    orderTroves[orderId] = nil
                end
    
                -- Remove assignments from chefs
                for _, chef in pairs(orderData.Assignments) do
                    if chef and chef:IsA("Player") then
                        chef:SetAttribute("OrderId", nil)
                    end
                end
    
                -- Notify clients to remove the order
                self.Client.UpdateOrder:FireAll({
                    OrderId = orderId,
                    Action = "CancelOrder",
                })
    
                activeOrders[orderId] = nil
    
                warn(`Order #{orderId} auto-cancelled due to player leave: {player.Name}`)
            end
        end
    end)
    

    Players.PlayerAdded:Connect(function(player)
        player:GetAttributeChangedSignal("Team"):Connect(function()
            if player:GetAttribute("Team") ~= "Chef" and player:GetAttribute("Team") ~= "Management" then
                self:_leaveQueue(player)
            end
        end)
    end)

    task.spawn(function()
        while true do
            task.wait(5)
            local stillUnassigned = {}
            for _, pending in ipairs(retryQueue) do
                local orderData = activeOrders[pending.OrderId]
                if orderData and not orderData.Completed[pending.Index] and not orderData.Assignments[pending.Index] then
                    local chef = self:PeekNextPlayer()
                    if chef then
                        chef = self:PopNextPlayer()
                        if chef then
                            orderData.Assignments[pending.Index] = chef
                            KitchenService:SelectItem(chef, pending.Item)
                            chef:SetAttribute("OrderId", pending.OrderId)

                            self.Client.UpdateOrder:FireAll({
                                OrderId = pending.OrderId,
                                Action = "AssignItem",
                                Index = pending.Index,
                                Chef = chef,
                                Item = pending.Item,
                            })

                            broadcastQueueUpdate(self)
                        end
                    else
                        table.insert(stillUnassigned, pending)
                    end
                end
            end
            retryQueue = stillUnassigned
        end
    end)
end

-- Client endpoints
function OrderService.Client:Submit(server: Player, orderDetails: table)
    return self.Server:_submit(server, orderDetails)
end

function OrderService.Client:JoinQueue(Player: Player)
    return self.Server:_joinQueue(Player, false)
end

function OrderService.Client:JoinQueuePurchased(Player: Player)
    return self.Server:_joinQueue(Player, true)
end

function OrderService.Client:LeaveQueue(Player: Player)
    return self.Server:_leaveQueue(Player)
end

function OrderService.Client:MarkItemDone(chef: Player, orderId: string, itemIndex: number)
    return self.Server:_markItemDone(chef, orderId, itemIndex)
end

function OrderService.Client:ClaimOrder(Server: Player, orderId: string)
    return self.Server:_claimOrder(Server, orderId)
end

function OrderService.Client:CancelOrder(Player: Player, orderId: string)
    return self.Server:_cancelOrder(Player, orderId)
end

return OrderService