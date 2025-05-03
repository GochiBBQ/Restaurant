--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players: Players = game:GetService("Players")
local HttpService: HttpService = game:GetService("HttpService")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)

-- Structures
local Queue: ModuleScript = require(Knit.Structures.Queue)
local HashSet: ModuleScript = require(Knit.Structures.HashSet)

-- Create Knit Service
local OrderService = Knit.CreateService {
    Name = "OrderService",
    Client = {
        UpdateQueue = Knit.CreateSignal(),
        UpdateOrder = Knit.CreateSignal(), -- Fired to assigned chefs
        OrderCompleted = Knit.CreateSignal(), -- Fired to original player
        ItemCompleted = Knit.CreateSignal(), -- Fired to assigned chefs
        UpdateUI = Knit.CreateSignal(), -- Fired to player
    },
}

-- Internal Structures
local priorityQueue = Queue.new()
local normalQueue = Queue.new()
local queuedUserIds = HashSet.new()
local joinTimes = {} -- [userId] = os.time()

-- Active Orders
local activeOrders: table = {} -- [orderId] = { Player, Table, Items, Assignments, Completed }

-- Variables
local KitchenService

-- Helper: Rebuild a queue excluding a specific UserId
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

-- Converts queue to array with join times
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

-- Broadcast queue to clients
local function broadcastQueueUpdate(self)
    self.Client.UpdateQueue:FireAll({
        priority = queueToTableWithJoinTimes(priorityQueue),
        normal = queueToTableWithJoinTimes(normalQueue),
    })
end

-- Assign chefs to items in order
local function assignChefsToOrder(self, orderDetails)
    local assignments = {}
    for i = 1, #orderDetails.Items do
        local chef = self:GetNextPlayer()
        if not chef then break end

        assignments[i] = chef
        
        KitchenService:SelectItem(chef, orderDetails.Items[i])
        chef:SetAttribute("OrderId", orderDetails.OrderId)

    end
    return assignments
end

-- Check if an order is fully completed
local function isOrderComplete(orderData)
    for i = 1, #orderData.Items do
        if not orderData.Completed[i] then
            return false
        end
    end
    return true
end

-- Server Functions

function OrderService:_submit(server: Player, orderDetails: table): boolean
    assert(server:IsA("Player"), "Expected a Player instance for 'server'")
    assert(type(orderDetails) == "table", "Expected a table for 'orderDetails'")
    assert(server:GetAttribute("Table"), "Server must have a valid Table attribute")
    assert(server:GetAttribute("Server"), "Server must have a valid Server attribute")
    assert(orderDetails.Player and orderDetails.Table and orderDetails.Items, "Missing order fields")

    local orderId = HttpService:GenerateGUID(false)
    orderDetails.OrderId = orderId -- Store the generated orderId in orderDetails for reference
    local assignments = assignChefsToOrder(self, orderDetails)

    activeOrders[orderId] = {
        Player = orderDetails.Player,
        Server = server, -- The server that submitted the order
        Table = orderDetails.Table,
        Items = orderDetails.Items,
        Assignments = assignments,
        Completed = {}, -- [index] = true when done
    }

    broadcastQueueUpdate(self)

    self.Client.UpdateOrder:FireAll({
        OrderId = orderId, -- The unique ID for this order
        Server = server, -- The server that submitted the order
        Player = orderDetails.Player, -- The player who made the order
        Action = "NewOrder", -- Action type for the clients to handle
        Table = orderDetails.Table,
        Items = orderDetails.Items, -- Pass the items in the order
        Assignments = assignments, -- Pass the chef assignments for each item
        Time = os.time(), -- Optional
    })

    return true
end

function OrderService:_markItemDone(chef: Player, orderId: string, itemName: string): boolean
	local orderData = activeOrders[orderId]
	if not orderData then return false end

	local foundIndex = nil
	for index, assignedChef in ipairs(orderData.Assignments) do
		if assignedChef == chef and orderData.Items[index] == itemName and not orderData.Completed[index] then
			foundIndex = index
			break
		end
	end

	if not foundIndex then
		warn(`Chef {chef.Name} is not assigned to item "{itemName}" or it's already completed.`)
		return false
	end

	orderData.Completed[foundIndex] = true

	-- Check if full order is done
	if isOrderComplete(orderData) then
		self.Client.OrderCompleted:Fire(orderData.Player, {
			Table = orderData.Table,
			Items = orderData.Items,
		})
		activeOrders[orderId] = nil -- Clean up
	end

    self.Client.UpdateOrder:FireAll({
        OrderId = orderId,
        ItemName = itemName,
        Action = "CompleteItem",
    })

    chef:SetAttribute("OrderId", nil) -- Clear the OrderId attribute for the chef

	return true
end


function OrderService:_joinQueue(Player: Player, Purchased: boolean?): boolean
    local userId = Player.UserId
    if queuedUserIds:contains(userId) then
        return false
    end

    if Purchased then
        priorityQueue:push(userId)
    else
        normalQueue:push(userId)
    end

    joinTimes[userId] = os.time()
    queuedUserIds:add(userId)

    broadcastQueueUpdate(self)

    return true
end

function OrderService:_leaveQueue(Player: Player): boolean
    local userId = Player.UserId
    if not queuedUserIds:contains(userId) then
        return false
    end

    priorityQueue = rebuildQueueExcluding(priorityQueue, userId)
    normalQueue = rebuildQueueExcluding(normalQueue, userId)
    queuedUserIds:remove(userId)
    joinTimes[userId] = nil

    broadcastQueueUpdate(self)
    self.Client.UpdateUI:Fire(Player, {
        Action = "LeaveQueue",
    })

    return true
end

function OrderService:GetNextPlayer(): Player?

    print(priorityQueue, normalQueue)

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

    Players.PlayerRemoving:Connect(function(player)
        self:_leaveQueue(player)
    end)

    Players.PlayerAdded:Connect(function(player)
        player:GetAttributeChangedSignal("Team"):Connect(function()
            if player:GetAttribute("Team") ~= "Chef" or player:GetAttribute("Team") ~= "Management" then
                self:_leaveQueue(player)
            end
        end)
    end)
end

-- Client Functions

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

-- Return to Knit
return OrderService
