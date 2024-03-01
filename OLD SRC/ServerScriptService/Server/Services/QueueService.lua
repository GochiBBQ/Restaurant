--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local QueueService = Knit.CreateService {
    Name = "QueueService",
	Client = {
        Update = Knit:CreateSignal(),
        Remove = Knit:CreateSignal(),
        Add = Knit:CreateSignal(),
	},
}

local NotificationService
Knit.ChefQueue = {}

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function QueueService:ElapsedTime()
    task.spawn(function()
        while task.wait(1) do
            for i, Chef in ipairs(Knit.ChefQueue) do
                Chef:SetAttribute("ElapsedTime", Chef:GetAttribute("ElapsedTime") + 1)
            end
        end
    end)
end

function QueueService:QueueJoin(Player: Player)
    if not table.find(Knit.ChefQueue, Player) then
        NotificationService:PlayerNotification(Player, "Joined 📝", "The server has successfully placed you inside of the chefs queue. Hang tight.")
        table.insert(Knit.ChefQueue, Player)
        Player:SetAttribute("ElapsedTime", 0)

        self.Client.Add:FireAll(Player)
        return table.find(Knit.ChefQueue, Player)
    else
        NotificationService:PlayerNotification(Player, "Uh Oh 😞", "You already hold a reserved slot in the queue. Please try again later.")
    end
end

function QueueService:QueueLeave(Player: Player)
    if table.find(Knit.ChefQueue, Player) then
        NotificationService:PlayerNotification(Player, "Left 📝", "The server has successfully removed you from the chefs queue.")
        table.remove(Knit.ChefQueue, table.find(Knit.ChefQueue, Player))
        Player:SetAttribute("ElapsedTime", nil)

        self.Client.Remove:FireAll(Player)
    else
        NotificationService:PlayerNotification(Player, "Uh Oh 😞", "You do not hold a reserved slot in the queue. Please join the queue first.")
    end
end

function QueueService:KnitStart()
    NotificationService = Knit.GetService("NotificationService")
    self:ElapsedTime()

    PlayerService.PlayerRemoving:Connect(function(Player)
        if table.find(Knit.ChefQueue, Player) then
            table.remove(Knit.ChefQueue, table.find(Knit.ChefQueue, Player))
            self.Client.Remove:FireAll(Player)
        end
    end)
end

function QueueService.Client:QueueJoin(Player: Player)
    return self.Server:QueueJoin(Player)
end

function QueueService.Client:QueueLeave(Player: Player)
    return self.Server:QueueLeave(Player)
end

function QueueService.Client:QueueUpdate(Player: Player)
    return Knit.ChefQueue
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return QueueService