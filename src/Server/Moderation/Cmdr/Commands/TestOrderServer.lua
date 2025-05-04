local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(context, players, item)
    local OrderService = Knit.GetService("OrderService")
    local KitchenService = Knit.GetService("KitchenService")

    for _, player in ipairs(players) do
        -- Ensure player is set up correctly
        player:SetAttribute("Table", 1)
        player:SetAttribute("Server", true)
        player:SetAttribute("Team", "Chef")

        -- Join chef queue
        OrderService:_joinQueue(player)

        -- Create fake order with the given item
        local orderDetails = {
            Player = player,
            Table = 1,
            Items = {item},
        }

        -- Submit the order
        local success = OrderService:_submit(player, orderDetails)

        -- Wait a tiny bit to let the order assign
        task.delay(1, function()
            -- Find the order (last one in activeOrders)
            for orderId, orderData in pairs(getfenv(1).activeOrders or {}) do
                if orderData.Player == player then
                    -- Mark the item as done
                    OrderService:_markItemDone(player, orderId, item)
                    break
                end
            end
        end)
    end
end
